import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    // Proxy vers l'API Gateway (dev uniquement)
    proxy: {
      '/api': {
        target: 'http://api-gateway:4000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
