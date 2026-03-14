# AIStash

**A native macOS app for storing, organizing, and searching AI-related assets.**

AIStash is a local-first, open-source macOS desktop application for managing your AI prompts, skills, agents, workflows, templates, and notes — all in one place, with no cloud dependency.

---

## Screenshots

> The app uses a standard macOS three-pane layout: Sidebar → Asset List → Detail Editor.

```
┌─────────────────────────────────────────────────────────────────────┐
│  AIStash                                                            │
├──────────────┬──────────────────────┬───────────────────────────────┤
│  Library     │  All Assets    [+]   │  System Prompt: Helpful…      │
│  ─────────── │  ─────────────────── │  ───────────────────────────  │
│  All Assets  │  🔵 System Prompt…   │  Type: [Prompt ▾]  ★ Fav      │
│  ★ Favorites │  🟢 Python Tool…     │  Folder: [Prompts ▾]          │
│  Archive     │  🟣 RAG Q&A Agent    │  Tags: [gpt-4o] [+]           │
│              │  🟠 Code Review…     │                               │
│  Folders     │  🔵 Chain-of-Tho…    │  Content                      │
│  ─────────── │                      │  ┌─────────────────────────┐  │
│  [+] Prompts │  Search: [       ]   │  │ You are a helpful,      │  │
│  Agents      │  Filters ▾           │  │ harmless, and honest…   │  │
│  Workflows   │                      │  └─────────────────────────┘  │
│  Research    │                      │                               │
│              │                      │  Metadata ▾                   │
│  Tags        │                      │  model: gpt-4o                │
│  ─────────── │                      │  temperature: 0.7             │
│  [+] gpt-4o  │                      │                               │
│  claude      │                      │  Created Mar 14, 2025         │
│  rag         │                      │  Modified 2 hours ago         │
└──────────────┴──────────────────────┴───────────────────────────────┘
```

---

## Features

| Feature | Status |
|---|---|
| Local-first persistence (SwiftData / SQLite) | ✅ |
| Six asset types: Prompt, Skill, Agent, Workflow, Template, Note | ✅ |
| Organize into Folders | ✅ |
| Tag assets with colored labels | ✅ |
| Full-text search (title, content, tags) | ✅ |
| Filter by type and tags | ✅ |
| Sort by modification date, creation date, or title | ✅ |
| Group by asset type | ✅ |
| Favorites and Archive | ✅ |
| Flexible metadata key-value editor | ✅ |
| Import / Export JSON | ✅ |
| Native macOS menu bar commands | ✅ |
| SwiftUI Previews with seed data | ✅ |
| Unit tests for filtering and import/export | ✅ |

---

## Requirements

| Requirement | Version |
|---|---|
| macOS | 14.0 (Sonoma) or later |
| Xcode | 15.0 or later |
| Swift | 5.9 or later |

> **Why macOS 14?** AIStash uses **SwiftData**, Apple's modern persistence framework introduced in macOS 14. It provides the cleanest, most Swift-native local storage available.

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-org/AIStash.git
cd AIStash
```

### 2. Open in Xcode

```bash
open AIStash.xcodeproj
```

Or double-click `AIStash.xcodeproj` in Finder.

### 3. Select a scheme and run

1. In Xcode, select the **AIStash** scheme from the scheme picker.
2. Choose **My Mac** as the destination.
3. Press **⌘R** to build and run.

The app will launch with sample seed data pre-populated so you can explore all features immediately.

> **Distribution note:** Current GitHub builds are not yet signed and notarized with Apple Developer ID. If you download a packaged app, macOS may show a warning such as `Apple could not verify "AIStash" is free of malware that may harm your Mac or compromise your privacy.`
>
> **How to bypass it for now**
> 1. Try opening `AIStash.app` once and let macOS block it.
> 2. Open **System Settings > Privacy & Security**.
> 3. Scroll to the security section near the bottom.
> 4. Find the message about `AIStash` being blocked and click **Open Anyway**.
> 5. Confirm by clicking **Open** in the follow-up dialog.
>
> You can also try **Control-click > Open** on the app in Finder, then choose **Open** from the dialog. This warning will go away once the app is distributed with proper Apple signing and notarization.

### 4. Run tests

```bash
# From the command line (requires Xcode Command Line Tools)
xcodebuild test -scheme AIStash -destination 'platform=macOS'

# Or press ⌘U in Xcode
```

---

## Project Structure

```
AIStash/
├── AIStash/
│   ├── App/
│   │   ├── AIStashApp.swift          # Entry point, SwiftData container setup
│   │   └── AppCommands.swift         # macOS menu bar commands (Cmd+N, export, import)
│   │
│   ├── Models/
│   │   ├── Asset.swift               # Core @Model: title, content, type, tags, metadata
│   │   ├── Asset+Hashable.swift      # Hashable conformance for SwiftUI List selection
│   │   ├── Folder.swift              # @Model: named collection of assets
│   │   ├── Tag.swift                 # @Model: colored label, many-to-many with Asset
│   │   ├── Tag+Hashable.swift        # Hashable conformance for Set<Tag> filter
│   │   ├── AssetType.swift           # Enum: Prompt | Skill | Agent | Workflow | Template | Note
│   │   └── SeedData.swift            # First-launch sample data injection
│   │
│   ├── ViewModels/
│   │   ├── SidebarViewModel.swift    # Sidebar selection, folder/tag CRUD
│   │   ├── AssetListViewModel.swift  # Filtering, sorting, asset CRUD
│   │   └── AssetDetailViewModel.swift # Editing, metadata, tag assignment
│   │
│   ├── Views/
│   │   ├── Main/
│   │   │   ├── ContentView.swift     # NavigationSplitView coordinator
│   │   │   └── SidebarView.swift     # Left pane: smart filters, folders, tags
│   │   ├── AssetList/
│   │   │   ├── AssetListView.swift   # Middle pane: search, filter, list
│   │   │   └── AssetRowView.swift    # Single list row component
│   │   ├── AssetDetail/
│   │   │   ├── AssetDetailView.swift # Right pane: full editor
│   │   │   └── MetadataEditorView.swift # Key-value metadata editor
│   │   └── Components/
│   │       ├── SearchBar.swift       # Debounced search input
│   │       ├── FilterPanel.swift     # Collapsible type + tag filter panel
│   │       ├── ImportExportView.swift # Import/export sheet
│   │       └── Color+Hex.swift       # SwiftUI Color from hex string
│   │
│   ├── Services/
│   │   └── ImportExportService.swift # JSON serialization/deserialization
│   │
│   └── Resources/
│       ├── Info.plist
│       └── PreviewData.swift         # In-memory container for SwiftUI Previews
│
├── AIStashTests/
│   ├── AssetFilterTests.swift        # Unit tests: filtering logic
│   └── ImportExportTests.swift       # Unit tests: JSON round-trip
│
├── Package.swift                     # SPM support for tooling/CI
├── .gitignore
├── LICENSE                           # MIT
└── README.md
```

---

## Architecture

AIStash follows **MVVM** (Model-View-ViewModel) with a clean separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                        Views                            │
│  (SwiftUI — declarative, no business logic)             │
│  ContentView → SidebarView, AssetListView, DetailView   │
└────────────────────────┬────────────────────────────────┘
                         │ observes / binds to
┌────────────────────────▼────────────────────────────────┐
│                     ViewModels                          │
│  (@Observable — state, user intents, filtering logic)   │
│  SidebarVM, AssetListVM, AssetDetailVM                  │
└────────────────────────┬────────────────────────────────┘
                         │ reads/writes
┌────────────────────────▼────────────────────────────────┐
│                 Models + Services                       │
│  (SwiftData @Model — Asset, Folder, Tag)                │
│  (ImportExportService — JSON serialization)             │
└─────────────────────────────────────────────────────────┘
```

**Key design decisions:**

- **SwiftData over Core Data:** SwiftData provides a Swift-native, macro-based API that eliminates boilerplate. It uses the same SQLite backend as Core Data but with far less ceremony.
- **In-memory filtering over @Query predicates:** Asset filtering is performed in-memory after a `@Query` fetches all assets. This keeps the filtering logic in the ViewModel (easily testable) rather than scattered across SwiftData predicates.
- **`@Observable` over `ObservableObject`:** The new `@Observable` macro (macOS 14+) is more efficient than `ObservableObject` — it tracks only the specific properties accessed by each view, reducing unnecessary re-renders.
- **Notification-based menu integration:** macOS menu commands post `NotificationCenter` notifications that views observe via `.onReceive`. This avoids the need for a global app state singleton.

---

## Data Model

### Asset

The central entity. Every AI artifact you store is an `Asset`.

| Property | Type | Description |
|---|---|---|
| `id` | UUID | Stable unique identifier |
| `title` | String | Display name |
| `content` | String | The main text body |
| `typeRawValue` | String | Serialized `AssetType` enum |
| `creationDate` | Date | Set on creation, never changed |
| `modificationDate` | Date | Updated on every edit via `touch()` |
| `isFavorite` | Bool | Pinned to Favorites smart filter |
| `isArchived` | Bool | Hidden from main views |
| `folder` | Folder? | Optional parent folder |
| `tags` | [Tag] | Many-to-many relationship |
| `metadataJSON` | Data? | JSON-encoded `[String: String]` dictionary |

### Folder

A named collection. Deleting a folder sets `asset.folder = nil` (nullify delete rule).

### Tag

A colored label. Many-to-many with Asset. Deleting a tag removes it from all assets.

---

## JSON Export Format

```json
{
  "version": 1,
  "exportDate": "2025-03-14T12:00:00Z",
  "folders": [
    { "id": "...", "name": "Prompts", "iconName": "text.bubble", "colorHex": "#4A90D9", "order": 0 }
  ],
  "tags": [
    { "id": "...", "name": "gpt-4o", "colorHex": "#10A37F" }
  ],
  "assets": [
    {
      "id": "...",
      "title": "System Prompt: Helpful Assistant",
      "content": "You are a helpful...",
      "type": "Prompt",
      "creationDate": "2025-03-14T10:00:00Z",
      "modificationDate": "2025-03-14T11:30:00Z",
      "isFavorite": true,
      "isArchived": false,
      "folderName": "Prompts",
      "tags": ["gpt-4o"],
      "metadata": { "model": "gpt-4o", "temperature": "0.7" }
    }
  ]
}
```

---

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `⌘N` | New Asset |
| `⌘⇧E` | Open Export sheet |
| `⌘⇧I` | Open Import sheet |

---

## Contributing

Contributions are welcome. Please follow these guidelines:

1. **Fork** the repository and create a feature branch: `git checkout -b feature/my-feature`
2. **Keep files small and focused.** Each file should have a single, clear responsibility.
3. **Write tests** for any new filtering, sorting, or service logic.
4. **Follow the existing naming conventions** (descriptive, no abbreviations).
5. **Open a pull request** with a clear description of the change and why it's needed.

### Suggested contributions

- iCloud sync via CloudKit (the SwiftData container supports this with a one-line change)
- Markdown rendering in the content editor
- Syntax highlighting for code-type assets
- Bulk operations (select multiple, batch tag, batch move to folder)
- Quick capture via a menu bar popover
- Spotlight integration via `NSUserActivity`

---

## Roadmap

| Phase | Status | Description |
|---|---|---|
| Phase 1 | ✅ Complete | Architecture, data model, folder structure |
| Phase 2 | ✅ Complete | App shell, three-pane layout, local persistence, seed data |
| Phase 3 | ✅ Complete | Search, tagging, grouping, filtering, sort |
| Phase 4 | ✅ Complete | Import/Export JSON, unit tests, README |
| Phase 5 | Planned | iCloud sync, Markdown editor, syntax highlighting |
| Phase 6 | Planned | Menu bar quick capture, Spotlight integration |

---

## License

AIStash is released under the **MIT License**. See [LICENSE](LICENSE) for details.
