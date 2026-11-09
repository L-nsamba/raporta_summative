
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['**/*.test.js'],
    testTimeout: 15000,
    hookTimeout: 15000,

    // All test files share one Firestore emulator database.
    // Run them sequentially to avoid clearing data
    // while another test suite is executing.
    fileParallelism: false,
    maxWorkers: 1,
    minWorkers: 1,
  },
});
