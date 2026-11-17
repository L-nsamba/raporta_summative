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

const areaOne = 'area-1';
const areaTwo = 'area-2';

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
    const now = new Date();

    // Seed valid areas.
    await setDoc(doc(db, 'areas', areaOne), {
      name: 'Area One',
    });

    await setDoc(doc(db, 'areas', areaTwo), {
      name: 'Area Two',
    });

    // Seed citizen profile.
    await setDoc(doc(db, 'users', citizenId), {
      userId: citizenId,
      name: 'Original Citizen',
      email: 'citizen@example.com',
      role: 'citizen',
      areaId: areaOne,
      createdAt: now,
      updatedAt: now,
    });

    // Seed another citizen.
    await setDoc(doc(db, 'users', anotherCitizenId), {
      userId: anotherCitizenId,
      name: 'Another Citizen',
      email: 'another@example.com',
      role: 'citizen',
      areaId: areaTwo,
      createdAt: now,
      updatedAt: now,
    });

    // Seed official profile.
    await setDoc(doc(db, 'users', officialId), {
      userId: officialId,
      name: 'Test Official',
      email: 'official@example.com',
      role: 'official',
      areaId: areaOne,
      createdAt: now,
      updatedAt: now,
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

// ==========================================
// PROFILE READ PERMISSIONS
// ==========================================

describe('Profile read permissions', () => {
  test('citizen can read their own profile', async () => {
    await assertSucceeds(
      getDoc(doc(citizenDb(), 'users', citizenId)),
    );
  });

  test('citizen cannot read another profile', async () => {
    await assertFails(
      getDoc(doc(citizenDb(), 'users', anotherCitizenId)),
    );
  });

  test('official can read their own profile', async () => {
    await assertSucceeds(
      getDoc(doc(officialDb(), 'users', officialId)),
    );
  });

  test('official cannot read another users profile', async () => {
    await assertFails(
      getDoc(doc(officialDb(), 'users', citizenId)),
    );
  });

  test('unauthenticated user cannot read profiles', async () => {
    await assertFails(
      getDoc(doc(unauthenticatedDb(), 'users', citizenId)),
    );
  });
});

// ==========================================
// ALLOWED PROFILE UPDATES
// ==========================================

describe('Allowed profile updates', () => {
  test('citizen can update their name', async () => {
    await assertSucceeds(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        name: 'Updated Citizen',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen can update their registered area', async () => {
    await assertSucceeds(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        areaId: areaTwo,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen can update name and area together', async () => {
    await assertSucceeds(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        name: 'Updated Citizen',
        areaId: areaTwo,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('official can update their own name', async () => {
    await assertSucceeds(
      updateDoc(doc(officialDb(), 'users', officialId), {
        name: 'Updated Official',
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

// ==========================================
// PROTECTED PROFILE FIELDS
// ==========================================

describe('Protected profile fields', () => {
  test('citizen cannot change their role to official', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        role: 'official',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their email', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        email: 'changed@example.com',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot change their userId', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        userId: anotherCitizenId,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot modify createdAt', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot add unexpected fields', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        isAdmin: true,
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

// ==========================================
// UPDATE VALIDATION
// ==========================================

describe('Profile update validation', () => {
  test('citizen cannot update another users profile', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', anotherCitizenId), {
        name: 'Unauthorized Change',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('unauthenticated user cannot update a profile', async () => {
    await assertFails(
      updateDoc(doc(unauthenticatedDb(), 'users', citizenId), {
        name: 'Unauthorized Change',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot assign a nonexistent area', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        areaId: 'nonexistent-area',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  test('citizen cannot supply an arbitrary timestamp', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        name: 'Updated Citizen',
        updatedAt: new Date('2020-01-01'),
      }),
    );
  });

  test('citizen cannot update name without updating timestamp', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        name: 'Updated Citizen',
      }),
    );
  });

  test('citizen cannot change name to a non-string value', async () => {
    await assertFails(
      updateDoc(doc(citizenDb(), 'users', citizenId), {
        name: 12345,
        updatedAt: serverTimestamp(),
      }),
    );
  });
});

// ==========================================
// PROFILE DELETION
// ==========================================

describe('Profile deletion restrictions', () => {
  test('citizen cannot delete their profile', async () => {
    await assertFails(
      deleteDoc(doc(citizenDb(), 'users', citizenId)),
    );
  });

  test('official cannot delete their profile', async () => {
    await assertFails(
      deleteDoc(doc(officialDb(), 'users', officialId)),
    );
  });
});