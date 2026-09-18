---
name: sketchup-ruby-plugin
description: 'Develop, debug, review, and test SketchUp plugins written in Ruby. Use for SketchUp Ruby API work, extensions, commands, tools, model geometry, entities, observers, menus, toolbars, HtmlDialog UI, extension packaging, and SketchUp version compatibility.'
argument-hint: 'Describe the SketchUp plugin feature, bug, or Ruby API behavior to address.'
user-invocable: true
---

# SketchUp Ruby Plugin Development

## When to Use

Use this skill when working on a SketchUp extension or Ruby plugin, including:

- Creating or changing commands, menus, toolbars, and tools.
- Reading or modifying models, entities, geometry, attributes, components, groups, and materials.
- Implementing observers, selection behavior, model state, or persistence.
- Connecting Ruby code to `UI::HtmlDialog` or other SketchUp UI APIs.
- Debugging SketchUp console errors, API-version differences, invalid entity references, or undo behavior.
- Reviewing plugin structure, extension registration, loading, packaging, and compatibility.

## Working Assumptions

- Treat SketchUp 2023 as the default target unless the project declares another support range.
- Confirm the target SketchUp version and operating system when the API or UI behavior may differ.
- Prefer the public `Sketchup` and `UI` APIs and existing project conventions.
- Treat model edits as user-visible operations that must be undoable, valid, and safe when repeated.
- Keep extension registration separate from feature implementation so loading the extension does not unexpectedly modify the active model.
- Do not assume that a Ruby API method available in current SketchUp also exists in older supported versions.

## Procedure

1. **Locate the owning code path**
   - Inspect the extension entry point, registration code, feature modules, UI wiring, and nearby tests or manual test instructions.
   - Identify whether the request is about loading, command state, UI communication, model mutation, geometry calculation, observers, or packaging.
   - State one local hypothesis about the behavior and one focused check that could disconfirm it before editing.

2. **Check the SketchUp API contract**
   - Verify method names, argument types, return values, coordinate systems, units, and version availability against the project references or official SketchUp Ruby API documentation.
   - Distinguish `Sketchup::Entity`, `Sketchup::Drawingelement`, `Sketchup::Group`, `Sketchup::ComponentInstance`, and `Sketchup::ComponentDefinition` where identity and ownership matter.
   - Account for invalidated or erased entities before using stored references.

3. **Implement the smallest coherent change**
   - Follow the existing module namespace and file-loading pattern.
   - Use `model.start_operation` and `model.commit_operation` around user-visible model changes; ensure failures do not leave an operation open.
   - Use `model.abort_operation` when an operation cannot complete safely.
   - Prefer `Geom::Point3d`, `Geom::Vector3d`, `Geom::Transformation`, and SketchUp collections over ad hoc coordinate or string handling.
   - Avoid mutating collections while iterating unless the API explicitly supports it.
   - Keep UI callbacks thin: validate and normalize data at the boundary, then call Ruby domain code.
   - Do not add observers, menu items, toolbars, or dialog instances repeatedly when a command is invoked more than once.

4. **Handle geometry and model state deliberately**
   - Make the edit context explicit: active entities, group/component definition, and transformation into model coordinates.
   - Preserve or document whether coordinates are local or world-space.
   - Consider empty selections, locked entities, hidden entities, nested instances, non-manifold geometry, and duplicate invocation.
   - Use attribute dictionaries for plugin-owned persistent data and namespace their keys to avoid collisions.
   - Check entity validity before later callbacks or deferred UI actions use saved references.

5. **Handle UI and external input safely**
   - Validate dialog messages, selections, numeric values, units, and paths before using them.
   - Keep Ruby-to-JavaScript messages small and structured; avoid interpolating untrusted values into executable JavaScript.
   - Make dialog lifecycle idempotent and release or reuse callbacks appropriately.
   - Keep long-running work out of synchronous UI callbacks when it would block SketchUp.

6. **Validate the change**
   - Run the repository's Ruby tests, linting, formatting, or packaging checks if available.
   - If no automated harness exists, use a focused SketchUp Console or manual checklist covering: extension load, command invocation, empty and normal selection, repeated invocation, undo/redo, save/reopen, and the supported SketchUp versions.
   - For geometry changes, inspect the resulting entities and transformations in both a fresh model and a model containing nested groups/components.
   - For UI changes, verify dialog creation, reopen behavior, callback payload validation, cancel/close behavior, and error reporting.
   - Re-check that no unrelated files changed and that the extension still loads without side effects.

## Review Checklist

- [ ] Extension registration is idempotent and does not mutate the active model on load.
- [ ] Public APIs and version assumptions are verified.
- [ ] Model mutations have correct undo/abort behavior.
- [ ] Entity references are checked for validity and ownership.
- [ ] Local versus world transformations are explicit.
- [ ] Empty, repeated, canceled, locked, and nested cases are handled.
- [ ] Persistent attributes use a plugin-specific namespace.
- [ ] UI and callback input is validated at the boundary.
- [ ] Dialogs, observers, menus, and toolbars are not duplicated.
- [ ] Focused automated or manual validation covers the changed behavior.

## Useful SketchUp Patterns

### Undo-safe model mutation

```ruby
model = Sketchup.active_model
model.start_operation('Change geometry', true)

begin
  # Perform the smallest possible model mutation here.
  model.commit_operation
rescue StandardError
  model.abort_operation
  raise
end
```

Use the project's established error-reporting policy if it differs. Do not swallow exceptions that would leave the model or UI in an unknown state.

### Namespaced attributes

```ruby
DICTIONARY = 'MyPlugin'.freeze
KEY = 'feature_enabled'.freeze

entity.set_attribute(DICTIONARY, KEY, true)
enabled = entity.get_attribute(DICTIONARY, KEY, false)
```

Replace the example namespace with the actual plugin namespace and keep attribute values simple and serializable.

## Completion Standard

A task is complete when the requested behavior is implemented in the owning code path, SketchUp API and version assumptions are checked, model operations remain undo-safe, repeated use is idempotent, and a focused automated or manual validation has passed. Report any validation that could not be run because SketchUp itself is unavailable.
