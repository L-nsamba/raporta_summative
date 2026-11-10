import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';

import {
  doc,
  setDoc,
  updateDoc,
  serverTimestamp,
} from 'firebase/firestore';

import {
  beforeAll,
  afterAll,
  beforeEach,
  describe,
  test,
} from 'vitest';

const PROJECT_ID = 'demo-raporta';

let testEnv;

const citizenId = 'citizen-123';
const anotherCitizenId = 'citizen-456';
const officialId = 'official-123';

const reportId = 'report-123';

beforeAll(async () => {
  const rules = readFileSync(
    resolve(process.cwd(), '../firestore.rules'),
    'utf8',
  );

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();

  // Seed test data without applying security rules.
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users', citizenId), {
      userId: citizenId,
      name: 'Test Citizen',
      email: 'citizen@test.com',
      role: 'citizen',
      areaId: 'kimironko',
    });

    await setDoc(doc(db, 'users', anotherCitizenId), {
      userId: anotherCitizenId,
      name: 'Another Citizen',
      email: 'another@test.com',
      role: 'citizen',
      areaId: 'kimironko',
    });

    await setDoc(doc(db, 'users', officialId), {
      userId: officialId,
      name: 'Test Official',
      email: 'official@test.com',
      role: 'official',
      areaId: 'kimironko',
    });

    await setDoc(doc(db, 'areas', 'kimironko'), {
      name: 'Kimironko',
    });

    await setDoc(doc(db, 'agencies', 'roads_office'), {
      agencyId: 'roads_office',
      name: 'Roads Office',
      category: 'roads',
    });

    await setDoc(doc(db, 'reports', reportId), {
      userId: citizenId,
      areaId: 'kimironko',
      category: 'roads',
      description: 'Damaged road near campus',
      lat: -1.95,
      lng: 30.12,
      locationDescription: 'Near the main road',
      photoUrl: null,
      status: 'pending',
      declineReason: null,
      declineFeedback: null,
      agencyId: null,
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    });
  });
});

function citizenDb() {
  return testEnv.authenticatedContext(citizenId).firestore();
}


function anotherCitizenDb() {
  return testEnv.authenticatedContext(anotherCitizenId).firestore();
}

function officialDb() {
  return testEnv.authenticatedContext(officialId).firestore();
}

function unauthenticatedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

function newReport(overrides = {}) {
  return {
    userId: citizenId,
    areaId: 'kimironko',
    category: 'roads',
    description: 'A damaged road needs attention',
    lat: -1.95,
    lng: 30.12,
    locationDescription: 'Near the main road',
    photoUrl: null,
    status: 'pending',
    declineReason: null,
    declineFeedback: null,
    agencyId: null,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    deletedAt: null,
    ...overrides,
  };
}


describe('Report creation permissions', () => {
  test('citizen cannot create a report for another user', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', 'another-users-report'),
        newReport({
          userId: anotherCitizenId,
        }),
      ),
    );
  });

  test('citizen cannot create a report with resolved status', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', 'invalid-report'),
        newReport({
          status: 'resolved',
        }),
      ),
    );
  });

  test('citizen cannot create a report with an invalid area', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', 'invalid-area-report'),
        newReport({
          areaId: 'unknown-area',
        }),
      ),
    );
  });
});

describe('Report update permissions', () => {
  test('official can move pending report to under review', async () => {
    const db = officialDb();

    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'under_review',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official can forward report to an existing agency', async () => {
    const db = officialDb();

    // First move the report to under review.
    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'under_review',
        updatedAt: serverTimestamp(),
      }),
    );

    // Then forward it to an existing agency.
    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'forwarded',
        agencyId: 'roads_office',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official cannot forward report to a nonexistent agency', async () => {
    const db = officialDb();

    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'under_review',
        updatedAt: serverTimestamp(),
      }),
    );

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'forwarded',
        agencyId: 'unknown_agency',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official cannot skip directly from pending to resolved', async () => {
    const db = officialDb();

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'resolved',
        agencyId: 'roads_office',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official cannot move resolved report back to pending', async () => {
    const db = officialDb();

    // Seed a resolved report.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await updateDoc(
        doc(context.firestore(), 'reports', reportId),
        {
          status: 'resolved',
          agencyId: 'roads_office',
        },
      );
    });

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'pending',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official cannot modify the original report description', async () => {
    const db = officialDb();

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        description: 'Changed description',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official cannot decline without a valid reason', async () => {
    const db = officialDb();

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'declined',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official can decline with a valid reason', async () => {
    const db = officialDb();

    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'declined',
        declineReason: 'duplicate',
        declineFeedback: 'This issue has already been reported.',
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

describe('Citizen report restrictions', () => {
  test('citizen cannot change report status', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        status: 'under_review',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot modify another citizen report', async () => {
    const db = anotherCitizenDb();

    await assertFails(
      updateDoc(doc(db, 'reports', reportId), {
        description: 'Trying to edit another report',
      }),
    );
  });

  test('citizen can soft-delete their own pending report', async () => {
    const db = citizenDb();

    await assertSucceeds(
      updateDoc(doc(db, 'reports', reportId), {
        deletedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('unauthenticated user cannot read reports', async () => {
    const db = unauthenticatedDb();

    const { getDoc } = await import('firebase/firestore');

    await assertFails(
      getDoc(doc(db, 'reports', reportId)),
    );
  });
});
