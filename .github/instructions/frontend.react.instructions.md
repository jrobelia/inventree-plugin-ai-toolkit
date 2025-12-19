---
description: 'React + TypeScript patterns for InvenTree plugin frontend components'
applyTo: ['frontend/src/**/*.tsx', 'frontend/src/**/*.ts']
---

# Frontend React TypeScript Patterns

**Source**: Plugin creator templates (Panel.tsx, Dashboard.tsx, Settings.tsx)  
**References**: [PROJECT-CONTEXT.md](../../copilot/PROJECT-CONTEXT.md) for InvenTree context interface

## InvenTree Plugin Component Pattern

```typescript
import { useCallback, useEffect, useMemo, useState } from 'react';
import { checkPluginVersion, type InvenTreePluginContext } from '@inventreedb/ui';
import { ApiEndpoints, apiUrl, ModelType } from '@inventreedb/ui';

/**
 * Main plugin panel component.
 * 
 * @param context - InvenTree plugin context (see interface below)
 */
function MyPluginPanel({ context }: { context: InvenTreePluginContext }) {
    
    // Verify plugin compatibility with InvenTree version
    useEffect(() => {
        checkPluginVersion(context);
    }, []);
    
    // Extract part ID from context (type-safe)
    const partId = useMemo(() => {
        return context.model === ModelType.part ? context.id || null : null;
    }, [context.model, context.id]);
    
    // Component logic here...
    
    return (
        <div>Panel content</div>
    );
}

/**
 * Render function - InvenTree calls this to mount component.
 */
export function renderMyPanel(context: InvenTreePluginContext) {
    checkPluginVersion(context);
    return <MyPluginPanel context={context} />;
}
```

## InvenTree Context Interface

```typescript
interface InvenTreePluginContext {
    // Current model/page
    model: 'part' | 'stock' | 'build' | 'company' | 'purchaseorder' | 'salesorder';
    id: number | null;  // Current item ID
    instance: any;  // Full object data (use with caution)
    
    // User info
    user: {
        username: () => string;
        pk: () => number;
        is_staff: () => boolean;
        is_superuser: () => boolean;
    };
    
    // API client
    api: {
        get: (url: string) => Promise<any>;
        post: (url: string, data: any) => Promise<any>;
        put: (url: string, data: any) => Promise<any>;
        patch: (url: string, data: any) => Promise<any>;
        delete: (url: string) => Promise<any>;
    };
    
    // Navigation
    navigate: (url: string) => void;
    reloadInstance?: () => void;  // Refresh current page
    
    // Forms (modal forms)
    forms: {
        edit: (options: FormOptions) => FormController;
        create: (options: FormOptions) => FormController;
        delete: (options: FormOptions) => FormController;
    };
    
    // React Query client (for caching API calls)
    queryClient: QueryClient;
}
```

## API Calls with React Query

```typescript
import { useQuery } from '@tanstack/react-query';

function MyComponent({ context }: { context: InvenTreePluginContext }) {
    const partId = context.id;
    
    // Fetch data with automatic caching and refetching
    const { data, isLoading, error, refetch } = useQuery(
        {
            queryKey: ['myData', partId],  // Cache key
            queryFn: async () => {
                const url = `/plugin/my-plugin/endpoint/${partId}/`;
                return context.api.get(url)
                    .then(response => response.data)
                    .catch(error => {
                        console.error('API error:', error);
                        throw error;  // Let React Query handle retry
                    });
            },
            // Options
            enabled: !!partId,  // Only run if partId exists
            staleTime: 5000,  // Consider fresh for 5 seconds
            refetchOnWindowFocus: false,  // Don't refetch on tab focus
        },
        context.queryClient  // Use InvenTree's query client
    );
    
    if (isLoading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    
    return <div>{JSON.stringify(data)}</div>;
}
```

## Mantine UI Components

```typescript
import { 
    Alert, Badge, Button, Group, Stack, Text, Title,
    Table, Loader, Card, Divider
} from '@mantine/core';
import { notifications } from '@mantine/notifications';

function MyComponent() {
    return (
        <Stack gap="md">
            <Title order={2}>My Plugin</Title>
            
            <Alert title="Info" color="blue">
                This is an informational message
            </Alert>
            
            <Group>
                <Button 
                    onClick={() => {
                        notifications.show({
                            title: 'Success',
                            message: 'Operation completed',
                            color: 'green',
                        });
                    }}
                >
                    Click Me
                </Button>
                
                <Badge color="green">In Stock</Badge>
                <Badge color="red">Out of Stock</Badge>
            </Group>
            
            <Card shadow="sm" padding="lg">
                <Text>Card content</Text>
            </Card>
        </Stack>
    );
}
```

## State Management Patterns

```typescript
import { useState, useMemo, useCallback } from 'react';

function MyComponent({ context }: { context: InvenTreePluginContext }) {
    // Simple state
    const [count, setCount] = useState<number>(0);
    const [enabled, setEnabled] = useState<boolean>(false);
    
    // Expensive computation - only recalculate when dependencies change
    const filteredData = useMemo(() => {
        if (!data) return [];
        return data.filter(item => item.active);
    }, [data]);  // Only recalculate when data changes
    
    // Stable callback reference - prevents unnecessary re-renders
    const handleClick = useCallback(() => {
        console.log('Clicked with count:', count);
        setCount(prev => prev + 1);
    }, [count]);  // Include dependencies
    
    // Effect with cleanup
    useEffect(() => {
        const timer = setInterval(() => {
            console.log('Tick');
        }, 1000);
        
        return () => clearInterval(timer);  // Cleanup on unmount
    }, []);  // Empty array = run once on mount
    
    return <div>Component content</div>;
}
```

## Form Integration Pattern

```typescript
import { useCallback } from 'react';
import { Alert, Button } from '@mantine/core';
import { notifications } from '@mantine/notifications';

function MyComponent({ context }: { context: InvenTreePluginContext }) {
    const partId = context.id;
    
    // Create modal form controller
    const editForm = context.forms.edit({
        url: apiUrl(ApiEndpoints.part_list, partId),
        title: "Edit Part",
        preFormContent: (
            <Alert title="Custom Form" color="blue">
                This form is launched from a plugin!
            </Alert>
        ),
        fields: {
            name: {},
            description: {},
            category: {},
        },
        successMessage: null,  // Custom notification instead
        onFormSuccess: (data) => {
            notifications.show({
                title: 'Success',
                message: `Part ${data.name} updated successfully`,
                color: 'green',
            });
            context.reloadInstance?.();  // Refresh page data
        },
        onFormError: (error) => {
            notifications.show({
                title: 'Error',
                message: 'Failed to update part',
                color: 'red',
            });
        }
    });
    
    const handleEdit = useCallback(() => {
        editForm?.open();
    }, [editForm]);
    
    return (
        <Button onClick={handleEdit}>
            Edit Part
        </Button>
    );
}
```

## TypeScript Best Practices

**Type safety**:
```typescript
// ✅ GOOD: Explicit types
interface BomItem {
    id: number;
    name: string;
    quantity: number;
    available?: number;  // Optional property
}

const items: BomItem[] = [];

// ❌ BAD: any type (loses type safety)
const items: any[] = [];  // Don't do this

// ✅ GOOD: Type guards
function isValidPart(obj: any): obj is Part {
    return typeof obj === 'object' 
        && 'id' in obj 
        && 'name' in obj;
}
```

**Null safety**:
```typescript
// ✅ GOOD: Check before use
const partId = context.id;
if (partId === null) {
    return <div>No part selected</div>;
}
// Now TypeScript knows partId is number

// ✅ GOOD: Optional chaining
const partName = context.instance?.name ?? 'Unknown';

// ❌ BAD: Unsafe access
const partName = context.instance.name;  // Crashes if instance is null
```

## Fail-Fast Decision Tree (Frontend)

**Question**: Should I use optional chaining `?.` or default values?

1. **Is null/undefined a valid state?** (No data yet, optional field)
   - ✅ Yes → Use `?.` and `??` with sensible default
   - ❌ No → Validate early and return error UI

2. **Does null/undefined indicate a bug?** (Required prop missing)
   - ✅ Yes → Throw error or show error boundary
   - ❌ No → Continue to #3

3. **Can user recover from this state?** (Loading, permissions)
   - ✅ Yes → Show loading/error UI with action
   - ❌ No → Log error, show error boundary

**Examples**:

```typescript
// ❌ BAD: Hides bugs
const quantity = item?.quantity ?? 0;  // Is 0 correct default?
const total = quantity * price;  // Wrong calculation if quantity required

// ✅ GOOD: Fail fast
if (!item || item.quantity === undefined) {
    console.error('Invalid item:', item);
    return <Alert color="red">Invalid item data</Alert>;
}
const total = item.quantity * price;

// ✅ ALSO GOOD: Optional by design
const pageSize = config?.pageSize ?? 50;  // Sensible default for UI preference

// ❌ BAD: Silent error in production
try {
    const result = processData(data);
} catch (e) {
    // Swallows error, returns undefined
}

// ✅ GOOD: User-visible error
try {
    const result = processData(data);
} catch (e) {
    notifications.show({
        title: 'Error',
        message: `Failed to process data: ${e.message}`,
        color: 'red',
    });
    return <Alert color="red">Processing failed</Alert>;
}
```

## React Hooks Rules (CRITICAL)

**Rules of Hooks** (React will break if violated):

1. **Only call at top level** - Never in loops, conditions, or nested functions
2. **Only call from React functions** - Components or custom hooks
3. **Custom hooks must start with "use"**

```typescript
// ❌ BAD: Conditional hook
if (enabled) {
    const data = useQuery(...);  // BREAKS REACT!
}

// ✅ GOOD: Hook at top level, condition inside
const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    enabled: enabled,  // Condition as option
});

// ❌ BAD: Hook in loop
items.forEach(item => {
    const result = useMemo(() => process(item));  // BREAKS REACT!
});

// ✅ GOOD: Process in useMemo
const results = useMemo(() => {
    return items.map(item => process(item));
}, [items]);
```

## Performance Optimization

**Use useMemo for expensive calculations**:
```typescript
// ✅ GOOD: Memoize expensive filtering/sorting
const sortedData = useMemo(() => {
    return data
        .filter(item => item.active)
        .sort((a, b) => a.name.localeCompare(b.name));
}, [data]);  // Only recalculate when data changes

// ❌ BAD: Recalculates every render
const sortedData = data
    .filter(item => item.active)
    .sort((a, b) => a.name.localeCompare(b.name));
```

**Use useCallback for stable function references**:
```typescript
// ✅ GOOD: Stable callback prevents child re-renders
const handleClick = useCallback((id: number) => {
    console.log('Clicked:', id);
}, []);  // No dependencies = never changes

// ❌ BAD: New function every render
const handleClick = (id: number) => {
    console.log('Clicked:', id);
};  // Child components re-render unnecessarily
```

## Industry Best Practices

**Component Structure**:
- Keep components small (< 200 lines)
- Extract reusable logic to custom hooks
- Props interface at top of file
- Export render function for InvenTree integration

**Error Handling**:
- Show user-friendly error messages
- Log errors to console for debugging
- Use Error Boundaries for crash recovery
- Provide retry/recovery actions

**Accessibility**:
- Use semantic HTML
- Add ARIA labels for screen readers
- Keyboard navigation support
- Color contrast for readability

**Performance**:
- Memoize expensive computations
- Virtualize long lists (react-window)
- Lazy load components (React.lazy)
- Debounce search inputs

---

**When optional chaining hides bugs**: Ask user if null is valid state. Fail-fast reveals design issues.
