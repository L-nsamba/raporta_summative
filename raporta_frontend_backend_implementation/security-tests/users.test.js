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

    await setDoc(doc(db, 'areas', 'kimironko'), {
      name: 'Kimironko',
    });

    await setDoc(doc(db, 'areas', 'remera'), {
      name: 'Remera',
    });

    await setDoc(doc(db, 'users', citizenId), {
      userId: citizenId,
      name: 'Test Citizen',
      email: 'citizen@test.com',
      role: 'citizen',
      areaId: 'kimironko',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await setDoc(doc(db, 'users', anotherCitizenId), {
      userId: anotherCitizenId,
      name: 'Another Citizen',
      email: 'another@test.com',
      role: 'citizen',
      areaId: 'kimironko',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await setDoc(doc(db, 'users', officialId), {
      userId: officialId,
      name: 'Test Official',
      email: 'official@test.com',
      role: 'official',
      areaId: 'kimironko',
      createdAt: new Date(),
      updatedAt: new Date(),
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

function newCitizenDb() {
  return testEnv.authenticatedContext('new-citizen').firestore();
}

function unauthenticatedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

function newCitizenProfile(overrides = {}) {
  return {
    userId: citizenId,
    name: 'New Citizen',
    email: 'newcitizen@test.com',
    role: 'citizen',
    areaId: 'kimironko',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

describe('User profile creation', () => {
    test('authenticated user can create their own citizen profile', async () => {
    const db = newCitizenDb();

    await assertSucceeds(
        setDoc(
        doc(db, 'users', 'new-citizen'),
        newCitizenProfile({
            userId: 'new-citizen',
        }),
        ),
    );
});

  test('citizen cannot create an official profile', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'users', 'new-official'),
        newCitizenProfile({
          userId: 'new-official',
          role: 'official',
        }),
      ),
    );
  });

  test('citizen cannot create a profile for another user', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'users', anotherCitizenId),
        newCitizenProfile({
          userId: anotherCitizenId,
        }),
      ),
    );
  });

  test('citizen cannot create a profile with an invalid area', async () => {
    const db = citizenDb();

    await assertFails(
      setDoc(
        doc(db, 'users', 'new-citizen'),
        newCitizenProfile({
          userId: 'new-citizen',
          areaId: 'unknown-area',
        }),
      ),
    );
  });
});

describe('User profile read permissions', () => {
  test('citizen can read their own profile', async () => {
    const db = citizenDb();

    await assertSucceeds(
      getDoc(doc(db, 'users', citizenId)),
    );
  });

  test('citizen cannot read another users profile', async () => {
    const db = citizenDb();

    await assertFails(
      getDoc(doc(db, 'users', anotherCitizenId)),
    );
  });

  test('official can read their own profile', async () => {
    const db = officialDb();

    await assertSucceeds(
      getDoc(doc(db, 'users', officialId)),
    );
  });

  test('unauthenticated user cannot read a profile', async () => {
    const db = unauthenticatedDb();

    await assertFails(
      getDoc(doc(db, 'users', citizenId)),
    );
  });
});

describe('User profile update permissions', () => {
  test('citizen can update their own name', async () => {
    const db = citizenDb();

    await assertSucceeds(
      updateDoc(doc(db, 'users', citizenId), {
        name: 'Updated Citizen',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen can change their area to an existing area', async () => {
    const db = citizenDb();

    await assertSucceeds(
      updateDoc(doc(db, 'users', citizenId), {
        areaId: 'remera',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their role to official', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'users', citizenId), {
        role: 'official',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their user ID', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'users', citizenId), {
        userId: anotherCitizenId,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their email through this update rule', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'users', citizenId), {
        email: 'changed@test.com',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot update another users profile', async () => {
    const db = anotherCitizenDb();

    await assertFails(
      updateDoc(doc(db, 'users', citizenId), {
        name: 'Trying to change another user',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their area to a nonexistent area', async () => {
    const db = citizenDb();

    await assertFails(
      updateDoc(doc(db, 'users', citizenId), {
        areaId: 'unknown-area',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot delete their profile', async () => {
    const db = citizenDb();

    await assertFails(
      deleteDoc(doc(db, 'users', citizenId)),
    );
  });

  test('official cannot change their role to citizen', async () => {
    const db = officialDb();

    await assertFails(
      updateDoc(doc(db, 'users', officialId), {
        role: 'citizen',
        updatedAt: serverTimestamp(),
      }),
    );
  });
});
