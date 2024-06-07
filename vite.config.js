import { join, resolve } from 'path';

import react from "@vitejs/plugin-react";
import reactSwc from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite';

/// <reference types="vitest" />
// https://vitejs.dev/config/
/** @type {import('vite').UserConfig} */
export default defineConfig({
  root: 'frontend',
  plugins: [reactSwc(), react()],

  test: {
    include: ['**/__tests__/*.test.{ts,tsx}']
  },
  resolve: {
    alias: [
      {
        find: '@/',
        replacement: join(__dirname, 'frontend/'),
      },
    ],
  },
  server: {
    port: 5173,
    strictPort: true,
    hmr: {
      port: 5173,
    },
  },
  build: {
    outDir: resolve(__dirname, 'web'),
    emptyOutDir: true,
    rollupOptions: {
      input: {
        '': resolve(__dirname, 'frontend/index.html'),
      },
      output: {
        entryFileNames: `assets/[name]/bundle.js`,
        assetFileNames: (assetInfo) => {
          const { name } = assetInfo

          if (name === '.css') {
            // FIXME: Hotfix for a bug that somehow the extension disappears from the output of smarthr-ui/smarthr-ui.css.
            return `assets/[hash][extname][name]`
          } else {
            return `assets/[name][hash][extname]`
          }
        },
      },
    },
  },
});
