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
  getDoc,
  deleteDoc,
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
const deletedReportId = 'deleted-report-123';
const missingReportId = 'missing-report-123';

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

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    // Seed user profiles.
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

    // Seed an active report.
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

    // Seed a soft-deleted report.
    await setDoc(doc(db, 'reports', deletedReportId), {
      userId: citizenId,
      areaId: 'kimironko',
      category: 'roads',
      description: 'Deleted report',
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
      deletedAt: new Date(),
    });

    // Seed an existing upvote.
    await setDoc(
      doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      {
        userId: anotherCitizenId,
        createdAt: new Date(),
      },
    );
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

function newUpvote(userId = citizenId) {
  return {
    userId,
    createdAt: serverTimestamp(),
  };
}

describe('Upvote creation permissions', () => {
  test('citizen can upvote an active report', async () => {
    const db = citizenDb();

    await assertSucceeds(
      setDoc(
        doc(db, 'reports', reportId, 'upvotes', citizenId),
        newUpvote(),
      ),
    );
  });

  test('citizen cannot create an upvote for another user', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
        newUpvote(anotherCitizenId),
      ),
    );
  });

  test('citizen cannot upvote a deleted report', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', deletedReportId, 'upvotes', citizenId),
        newUpvote(),
      ),
    );
  });

  test('citizen cannot upvote a nonexistent report', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', missingReportId, 'upvotes', citizenId),
        newUpvote(),
      ),
    );
  });
});

describe('Upvote read permissions', () => {
  test('authenticated citizen can read upvotes', async () => {
    const db = citizenDb();

    await assertSucceeds(
      getDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      ),
    );
  });

  test('official can read upvotes', async () => {
    const db = officialDb();

    await assertSucceeds(
      getDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      ),
    );
  });

  test('unauthenticated user cannot read upvotes', async () => {
    const db = unauthenticatedDb();

    await assertFails(
      getDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      ),
    );
  });

  test('citizen cannot read upvotes on a deleted report', async () => {
    const db = citizenDb();

    await assertFails(
      getDoc(
        doc(db, 'reports', deletedReportId, 'upvotes', anotherCitizenId),
      ),
    );
  });
});

describe('Upvote modification permissions', () => {
  test('citizen cannot create a duplicate upvote', async () => {
    const db = anotherCitizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
        newUpvote(anotherCitizenId),
      ),
    );
  });

  test('citizen can remove their own upvote', async () => {
    const db = anotherCitizenDb();

    await assertSucceeds(
      deleteDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      ),
    );
  });

  test('citizen cannot remove another users upvote', async () => {
    const db = citizenDb();

    await assertFails(
      deleteDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
      ),
    );
  });

  test('citizen cannot modify an existing upvote', async () => {
    const db = anotherCitizenDb();

    await assertFails(
      setDoc(
        doc(db, 'reports', reportId, 'upvotes', anotherCitizenId),
        {
          userId: anotherCitizenId,
          createdAt: serverTimestamp(),
        },
      ),
    );
  });

  test('citizen cannot remove an upvote from a deleted report', async () => {
    const db = anotherCitizenDb();

    // Seed an upvote under the deleted report.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(
          context.firestore(),
          'reports',
          deletedReportId,
          'upvotes',
          anotherCitizenId,
        ),
        {
          userId: anotherCitizenId,
          createdAt: new Date(),
        },
      );
    });

    await assertFails(
      deleteDoc(
        doc(
          db,
          'reports',
          deletedReportId,
          'upvotes',
          anotherCitizenId,
        ),
      ),
    );
  });
});
