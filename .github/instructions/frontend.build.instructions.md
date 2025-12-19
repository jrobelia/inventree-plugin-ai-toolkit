---
description: 'Frontend build configuration - Vite, TypeScript, externalized dependencies'
applyTo: ['**/vite.config.ts', '**/vite.dev.config.ts', '**/tsconfig*.json']
---

# Frontend Build Configuration

**Source**: Plugin creator templates (vite.config.ts)  
**Tech Stack**: Vite 6, React 18, TypeScript, Mantine UI

## Vite Production Build Config

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteExternalsPlugin } from 'vite-plugin-externals';

/**
 * External libraries provided by InvenTree core.
 * DO NOT bundle these - InvenTree loads them globally.
 */
export const externalLibs: Record<string, string> = {
  react: 'React',
  'react-dom': 'ReactDOM',
  'ReactDom': 'ReactDOM',  // Legacy alias
  '@lingui/core': 'LinguiCore',
  '@lingui/react': 'LinguiReact',
  '@mantine/core': 'MantineCore',
  '@mantine/notifications': 'MantineNotifications',
  '@mantine/hooks': 'MantineHooks',
  '@mantine/dates': 'MantineDates',
  '@mantine/dropzone': 'MantineDropzone',
  '@tanstack/react-query': 'ReactQuery',
  '@inventreedb/ui': 'InventreeUI',
};

export default defineConfig({
  plugins: [
    react({
      jsxRuntime: 'classic',  // Required for InvenTree compatibility
    }),
    viteExternalsPlugin(externalLibs),  // Externalize dependencies
  ],
  esbuild: {
    jsx: 'preserve',  // Don't transform JSX
  },
  build: {
    target: 'esnext',
    outDir: '../my_plugin/static',  // Plugin static folder
    emptyOutDir: false,  // Don't delete other static files
    lib: {
      entry: './src/Panel.tsx',  // Entry point
      name: 'MyPluginPanel',
      fileName: 'Panel',
      formats: ['es'],  // ES module format
    },
    rollupOptions: {
      external: Object.keys(externalLibs),  // Don't bundle these
      output: {
        globals: externalLibs,  // Map to global variables
      },
    },
  },
});
```

## Why Externalize Dependencies?

**Problem**: Bundling React, Mantine, etc. with every plugin creates:
- Large bundle sizes (MB per plugin)
- Multiple React instances (breaks hooks)
- Version conflicts
- Slow load times

**Solution**: InvenTree loads libraries once, plugins reference them:

```typescript
// ❌ BAD: Import React (would bundle it)
import React from 'react';  // Bundled = duplicate React instance

// ✅ GOOD: Use externalized React (from InvenTree)
const React = window.React;  // Global from InvenTree
```

Vite's `viteExternalsPlugin` handles this automatically:
```typescript
// Your code
import { useState } from 'react';

// Compiled output
const { useState } = window.React;  // Uses InvenTree's React
```

## TypeScript Configuration

**tsconfig.json** (Base config):
```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "lib": ["ESNext", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "strict": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "../my_plugin/static"]
}
```

**tsconfig.app.json** (App-specific):
```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "types": ["node"]
  },
  "include": ["src"]
}
```

**tsconfig.node.json** (Vite config):
```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "module": "ESNext",
    "types": ["node"]
  },
  "include": ["vite.config.ts", "vite.dev.config.ts"]
}
```

## Development Build Config

**vite.dev.config.ts** (Hot reload for development):
```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteExternalsPlugin, externalLibs } from './vite.config';

export default defineConfig({
  plugins: [
    react({
      jsxRuntime: 'classic',
    }),
    viteExternalsPlugin(externalLibs),
  ],
  server: {
    port: 5173,  // Dev server port
    open: false,  // Don't auto-open browser
    cors: true,  // Enable CORS for InvenTree
  },
  build: {
    outDir: '../my_plugin/static',
    emptyOutDir: false,
    sourcemap: true,  // Enable source maps for debugging
    minify: false,  // Don't minify for development
  },
});
```

## Build Scripts

**package.json**:
```json
{
  "name": "my-plugin-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --config vite.dev.config.ts",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "biome check .",
    "format": "biome format --write ."
  },
  "dependencies": {
    "@inventreedb/ui": "^1.0.0",
    "@lingui/core": "^5.1.0",
    "@lingui/react": "^5.1.0",
    "@mantine/core": "^7.15.2",
    "@mantine/hooks": "^7.15.2",
    "@mantine/notifications": "^7.15.2",
    "@tanstack/react-query": "^5.62.11",
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.4",
    "@types/react": "^18.3.1",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.7.3",
    "vite": "^6.0.0",
    "vite-plugin-externals": "^0.6.2"
  }
}
```

## Build Process

```bash
# Install dependencies
npm install

# Development (hot reload)
npm run dev

# Production build
npm run build
# Output: my_plugin/static/Panel.js

# Type checking
npm run tsc

# Linting
npm run lint
npm run format
```

## Common Build Issues

**Issue**: "React" is not defined
```typescript
// ❌ Problem: React not externalized
import React from 'react';

// ✅ Solution: Add to externalLibs in vite.config.ts
export const externalLibs = {
  react: 'React',  // Maps to window.React
  // ...
};
```

**Issue**: Multiple React instances (hooks break)
```
Error: Invalid hook call. Hooks can only be called inside...
```
```typescript
// ✅ Solution: Ensure React is externalized, not bundled
// Check vite.config.ts has viteExternalsPlugin
```

**Issue**: Module not found: @inventreedb/ui
```bash
# ✅ Solution: Install InvenTree UI package
npm install @inventreedb/ui
```

**Issue**: Build output not loading in InvenTree
```python
# ✅ Solution: Check static folder path in vite.config.ts
build: {
  outDir: '../my_plugin/static',  # Must match plugin static folder
  # ...
}
```

## Performance Optimization

**Code splitting** (load on demand):
```typescript
import { lazy, Suspense } from 'react';

// Lazy load heavy component
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function MyPanel() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}
```

**Tree shaking** (remove unused code):
```typescript
// ✅ GOOD: Import only what you need
import { Button, Stack } from '@mantine/core';

// ❌ BAD: Imports entire library
import * as Mantine from '@mantine/core';
```

**Bundle analysis**:
```bash
# Analyze bundle size
npm run build -- --mode production
# Check my_plugin/static/Panel.js size

# Should be < 100KB for simple plugins
# Should be < 500KB for complex plugins
```

## Industry Best Practices

**Build Configuration**:
- Externalize shared dependencies (React, Mantine)
- Enable source maps for development
- Minify for production
- Use TypeScript strict mode

**Development Workflow**:
- Hot reload during development (`npm run dev`)
- Type check before build (`tsc`)
- Lint code (`npm run lint`)
- Test in InvenTree after build

**Performance**:
- Lazy load large components
- Tree shake unused code
- Monitor bundle size
- Compress static assets

**Debugging**:
- Enable source maps in development
- Use React DevTools
- Check browser console for errors
- Verify external libraries loaded

---

**Build issues?** Check that external libraries are loaded by InvenTree and plugin static folder path is correct.
