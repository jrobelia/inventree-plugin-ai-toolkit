---
applyTo: "**/*.ts,**/*.tsx,!frontend/src/**"
---

# TypeScript and React Conventions

General TypeScript and React patterns. For framework-specific patterns
(InvenTree context, Mantine, Vite build), see domain instruction files.

---

## TypeScript

- **Strict mode always.** Enable `strict: true` in `tsconfig.json`.
- **Explicit interfaces** over inline types for anything used in more than
  one place.
- **No `any`.** Use `unknown` and narrow with type guards when the type is
  genuinely uncertain.
- **Prefer `const` over `let`.** Never use `var`.
- **Enum alternatives.** Prefer `as const` objects or union types over
  TypeScript enums for better tree-shaking.

### Naming

- Interfaces/types: `PascalCase` (e.g. `BomRow`, `PluginConfig`).
- Functions/variables: `camelCase`.
- Constants: `UPPER_SNAKE_CASE` for true compile-time constants.
- Files: `PascalCase.tsx` for components, `camelCase.ts` for utilities.

---

## React

### Rules of Hooks (non-negotiable)

- Call hooks at the **top level only** -- never inside conditions, loops,
  or nested functions.
- Call hooks only from React function components or custom hooks.

### Performance

- `useMemo` for expensive calculations that depend on specific values.
- `useCallback` for function references passed as props to child components.
- Avoid creating objects/arrays inside JSX -- they cause unnecessary re-renders.

### State Management

- Prefer local state (`useState`) over global state.
- Lift state up only when two components actually need to share it.
- Use `useReducer` for complex state logic with multiple transitions.

### Component Structure

```tsx
// 1. Imports
import { useState, useMemo } from 'react';

// 2. Types/interfaces
interface Props {
  partId: number;
  onComplete: (result: BomResult) => void;
}

// 3. Component
export function BomPanel({ partId, onComplete }: Props) {
  // hooks first
  const [loading, setLoading] = useState(false);

  // derived values
  const label = useMemo(() => computeLabel(partId), [partId]);

  // handlers
  const handleClick = useCallback(() => {
    // ...
  }, [partId]);

  // render
  return <div>{label}</div>;
}
```

### Error Handling

- Use error boundaries for component-level failures.
- Show user-friendly error messages, not stack traces.
- Log detailed errors to the console for debugging.

---

## General Rules

- No emoji in code strings. Use ASCII: `[OK]`, `[ERROR]`.
- Keep components small -- if a component exceeds ~100 lines, split it.
- Co-locate tests with source: `Widget.tsx` next to `Widget.test.tsx`.
