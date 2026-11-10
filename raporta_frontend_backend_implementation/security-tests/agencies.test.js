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
  updateDoc,
  deleteDoc,
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
const officialId = 'official-123';

const agencyId = 'roads_office';

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

    await setDoc(doc(db, 'users', citizenId), {
      userId: citizenId,
      name: 'Test Citizen',
      email: 'citizen@test.com',
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

    await setDoc(doc(db, 'agencies', agencyId), {
      agencyId: agencyId,
      name: 'Roads Office',
      category: 'roads',
    });
  });
});

function citizenDb() {
  return testEnv.authenticatedContext(citizenId).firestore();
}

function officialDb() {
  return testEnv.authenticatedContext(officialId).firestore();
}

function unauthenticatedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

describe('Agency read permissions', () => {
  test('citizen can read an agency', async () => {
    const db = citizenDb();

    await assertSucceeds(
      getDoc(doc(db, 'agencies', agencyId)),
    );
  });

  test('official can read an agency', async () => {
    const db = officialDb();

    await assertSucceeds(
      getDoc(doc(db, 'agencies', agencyId)),
    );
  });

  test('unauthenticated user cannot read an agency', async () => {
    const db = unauthenticatedDb();

    await assertFails(
      getDoc(doc(db, 'agencies', agencyId)),
    );
  });
});

describe('Agency creation permissions', () => {
  test('citizen cannot create an agency', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(doc(db, 'agencies', 'new_agency'), {
        agencyId: 'new_agency',
        name: 'New Agency',
        category: 'other',
      }),
    );
  });

  test('official cannot create an agency', async () => {
    const db = officialDb();

    await assertFails(
      setDoc(doc(db, 'agencies', 'new_agency'), {
        agencyId: 'new_agency',
        name: 'New Agency',
        category: 'other',
      }),
    );
  });
});

describe('Agency modification permissions', () => {
  test('citizen cannot update an agency', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'agencies', agencyId), {
        name: 'Modified Agency',
      }),
    );
  });

  test('official cannot update an agency', async () => {
    const db = officialDb();

    await assertFails(
      updateDoc(doc(db, 'agencies', agencyId), {
        name: 'Modified Agency',
      }),
    );
  });

  test('citizen cannot delete an agency', async () => {
    const db = citizenDb();

    await assertFails(
      deleteDoc(doc(db, 'agencies', agencyId)),
    );
  });

  test('official cannot delete an agency', async () => {
    const db = officialDb();

    await assertFails(
      deleteDoc(doc(db, 'agencies', agencyId)),
    );
  });
});
