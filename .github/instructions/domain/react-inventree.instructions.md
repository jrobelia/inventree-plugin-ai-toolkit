---
applyTo: "frontend/src/**/*.tsx,frontend/src/**/*.ts,**/vite.config.ts,**/vite.*.config.ts,**/tsconfig*.json"
---

# InvenTree React Frontend and Build Patterns

Patterns specific to InvenTree plugin frontend development and the Vite
build pipeline. For general TypeScript/React conventions, see
`typescript.instructions.md`.

---

## Architecture Rules

InvenTree plugin components are **embedded** in the InvenTree UI:
- Do NOT use client-side routing -- InvenTree handles navigation.
- Do NOT manage authentication -- use `context.user`.
- Do NOT manage global app state -- InvenTree provides context.
- Do NOT bundle React, Mantine, or other shared libraries.

---

## InvenTree Plugin Context

```typescript
interface InvenTreePluginContext {
    model: 'part' | 'stock' | 'build' | 'company' | 'purchaseorder' | 'salesorder';
    id: number | null;
    instance: any;
    user: {
        username: () => string;
        pk: () => number;
        is_staff: () => boolean;
    };
    api: {
        get: (url: string) => Promise<any>;
        post: (url: string, data: any) => Promise<any>;
        put: (url: string, data: any) => Promise<any>;
        delete: (url: string) => Promise<any>;
    };
    navigate: (url: string) => void;
    queryClient: QueryClient;
}
```

---

## Component Pattern

```typescript
import { useCallback, useEffect, useMemo, useState } from 'react';
import { checkPluginVersion, type InvenTreePluginContext } from '@inventreedb/ui';

function MyPanel({ context }: { context: InvenTreePluginContext }) {
    useEffect(() => { checkPluginVersion(context); }, []);

    const partId = useMemo(() => {
        return context.model === 'part' ? context.id : null;
    }, [context.model, context.id]);

    return <div>Panel content</div>;
}

export function renderMyPanel(context: InvenTreePluginContext) {
    checkPluginVersion(context);
    return <MyPanel context={context} />;
}
```

---

## API Calls with React Query

```typescript
import { useQuery } from '@tanstack/react-query';

const { data, isLoading, error } = useQuery(
    {
        queryKey: ['myData', partId],
        queryFn: async () => {
            const url = `/plugin/my-plugin/endpoint/${partId}/`;
            return context.api.get(url).then(r => r.data);
        },
        enabled: !!partId,
        staleTime: 5000,
    },
    context.queryClient     // Use InvenTree's query client
);
```

---

## Mantine UI Components

InvenTree PUI is built on **Mantine v7** + **Mantine DataTable** + **`@tabler/icons-react`**.
Plugin panels render inside PUI -- use the same stack or they look broken.
Do NOT use Material UI, Ant Design, or raw HTML tables.

```typescript
import { Alert, Badge, Button, Card, Group, Stack, Text, Title } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { IconPlug } from '@tabler/icons-react';  // Tabler icons, not FontAwesome
```

Key InvenTree wrapper components:
- `<InvenTreeTable>` -- wraps Mantine DataTable with server-side pagination/filtering
- `<ApiForm>` -- wraps Mantine `useForm` + auto-maps DRF serializer fields
- Modals via Mantine `modals.show()` manager
- Theme colors via `useMantineTheme()` -- never hardcode hex values

---

## Dependency Externalization (WHY)

InvenTree loads React, Mantine, etc. once globally. Bundling them in each
plugin causes:
- Large bundle sizes (MB per plugin).
- Multiple React instances (breaks hooks).
- Version conflicts.

Vite's `viteExternalsPlugin` converts imports to global references
automatically.

---

## Vite Production Config (vite.config.ts)

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { viteExternalsPlugin } from 'vite-plugin-externals';

// Libraries provided by InvenTree core -- DO NOT bundle
export const externalLibs: Record<string, string> = {
    react: 'React',
    'react-dom': 'ReactDOM',
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
        react({ jsxRuntime: 'classic' }),
        viteExternalsPlugin(externalLibs),
    ],
    build: {
        target: 'esnext',
        outDir: '../my_plugin/static',
        emptyOutDir: false,
        lib: {
            entry: './src/Panel.tsx',
            name: 'MyPluginPanel',
            fileName: 'Panel',
            formats: ['es'],
        },
        rollupOptions: {
            external: Object.keys(externalLibs),
            output: { globals: externalLibs },
        },
    },
});
```

---

## TypeScript Config (tsconfig.json)

```json
{
    "compilerOptions": {
        "target": "ESNext",
        "module": "ESNext",
        "lib": ["ESNext", "DOM", "DOM.Iterable"],
        "jsx": "react-jsx",
        "strict": true,
        "moduleResolution": "bundler",
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true
    },
    "include": ["src/**/*"],
    "exclude": ["node_modules", "dist"]
}
```

---

## Build Scripts (package.json)

```json
{
    "scripts": {
        "dev": "vite --config vite.dev.config.ts",
        "build": "tsc && vite build",
        "preview": "vite preview"
    }
}
```

---

## Plugin Panel Registration (Python Side)

```python
def get_custom_panels(self, view, request):
    panels = []
    # 'view' is the page class -- use it to target specific pages
    if view.__class__.__name__ == 'PartDetail':
        panels.append({
            'title': 'My Panel',
            'icon': 'ti-plug',              # Tabler icon class
            'content_template': 'my_plugin/my_panel.html',
        })
    return panels
```

---

## Build Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `React is not defined` at runtime | Missing external | Add to `externalLibs` |
| Hooks error (invalid hook call) | Bundled duplicate React | Verify externalization |
| TypeScript errors on build | Missing types | Install `@types/react` as devDependency |
| Output in wrong folder | `outDir` path wrong | Check relative path to plugin static folder |
