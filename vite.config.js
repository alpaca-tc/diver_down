import { join, resolve } from 'path';

import reactRefresh from "@vitejs/plugin-react-refresh";
import reactSwc from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  root: 'frontend',
  plugins: [reactSwc(), reactRefresh()],
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
      },
    },
  },
});
