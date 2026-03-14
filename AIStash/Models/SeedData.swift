// SeedData.swift
// Inserts sample assets, folders, and tags on the very first app launch.
//
// This gives new users a populated app to explore immediately.
// We use a simple UserDefaults flag to ensure seeding only happens once.
// The seed data covers all AssetType cases so the UI is fully exercisable.

import Foundation
import SwiftData

public enum SeedData {

    public static func insertIfNeeded(into context: ModelContext) {
        let key = "AIStash.seedDataInserted.v1"
        normalizeLibraryIfNeeded(in: context)

        if libraryAlreadySeeded(in: context) {
            UserDefaults.standard.set(true, forKey: key)
            return
        }

        guard !UserDefaults.standard.bool(forKey: key) else { return }

        // --- Tags ---
        let tagGPT4    = Tag(name: "gpt-4o",     colorHex: "#10A37F")
        let tagClaude  = Tag(name: "claude",      colorHex: "#D4A017")
        let tagRAG     = Tag(name: "rag",         colorHex: "#7B68EE")
        let tagPython  = Tag(name: "python",      colorHex: "#3776AB")
        let tagProd    = Tag(name: "production",  colorHex: "#E74C3C")

        context.insert(tagGPT4)
        context.insert(tagClaude)
        context.insert(tagRAG)
        context.insert(tagPython)
        context.insert(tagProd)

        // --- Folders ---
        let folderPrompts   = Folder(name: "Prompts",    iconName: "text.bubble",           colorHex: "#4A90D9", order: 0)
        let folderAgents    = Folder(name: "Agents",     iconName: "cpu",                   colorHex: "#9B59B6", order: 1)
        let folderWorkflows = Folder(name: "Workflows",  iconName: "arrow.triangle.branch", colorHex: "#E67E22", order: 2)
        let folderResearch  = Folder(name: "Research",   iconName: "doc.text.magnifyingglass", colorHex: "#27AE60", order: 3)

        context.insert(folderPrompts)
        context.insert(folderAgents)
        context.insert(folderWorkflows)
        context.insert(folderResearch)

        // --- Assets ---

        let a1 = Asset(
            title: "System Prompt: Helpful Assistant",
            content: """
            You are a helpful, harmless, and honest AI assistant.
            Always respond in clear, concise language.
            If you are unsure about something, say so rather than guessing.
            Prefer bullet points for lists and code blocks for code.
            """,
            type: .prompt,
            isFavorite: true,
            folder: folderPrompts,
            tags: [tagGPT4],
            metadata: ["model": "gpt-4o", "temperature": "0.7"]
        )

        let a2 = Asset(
            title: "Chain-of-Thought Reasoning Prompt",
            content: """
            Solve the following problem step by step.
            Think through each step carefully before providing your final answer.
            Format your response as:
            Step 1: [reasoning]
            Step 2: [reasoning]
            ...
            Final Answer: [answer]
            """,
            type: .prompt,
            folder: folderPrompts,
            tags: [tagGPT4, tagClaude],
            metadata: ["model": "gpt-4o", "temperature": "0.2"]
        )

        let a3 = Asset(
            title: "RAG Document Q&A Agent",
            content: """
            # RAG Q&A Agent

            ## Description
            An agent that retrieves relevant document chunks from a vector store
            and synthesizes a grounded answer.

            ## Tools
            - `search_documents(query: str) -> List[Chunk]`
            - `rerank_chunks(chunks: List[Chunk], query: str) -> List[Chunk]`
            - `generate_answer(context: str, question: str) -> str`

            ## System Prompt
            You are a document Q&A agent. Always cite your sources.
            Only answer based on the retrieved context. If the answer is not
            in the context, say "I don't have enough information."
            """,
            type: .agent,
            isFavorite: true,
            folder: folderAgents,
            tags: [tagRAG, tagGPT4],
            metadata: ["model": "gpt-4o", "vector_store": "pgvector"]
        )

        let a4 = Asset(
            title: "Code Review Workflow",
            content: """
            # Automated Code Review Workflow

            1. **Trigger:** Pull request opened or updated
            2. **Step 1 – Linting:** Run ESLint / Ruff / SwiftLint
            3. **Step 2 – Static Analysis:** Run Semgrep security rules
            4. **Step 3 – LLM Review:**
               - Summarize changes
               - Identify potential bugs
               - Suggest improvements
            5. **Step 4 – Post Comment:** Post structured review to PR
            6. **Step 5 – Label:** Apply `needs-review` or `approved` label

            ## LLM Prompt Template
            Review the following diff and provide feedback on:
            - Correctness
            - Security vulnerabilities
            - Performance
            - Code style
            """,
            type: .workflow,
            folder: folderWorkflows,
            tags: [tagPython, tagGPT4, tagProd],
            metadata: ["trigger": "pull_request", "language": "python"]
        )

        let a5 = Asset(
            title: "Blog Post Writer Template",
            content: """
            # Blog Post: {{TOPIC}}

            **Target audience:** {{AUDIENCE}}
            **Tone:** {{TONE}}
            **Word count:** ~{{WORD_COUNT}}

            ---

            ## Introduction
            [Hook the reader with a compelling opening about {{TOPIC}}]

            ## Section 1: {{SECTION_1_TITLE}}
            [Main content]

            ## Section 2: {{SECTION_2_TITLE}}
            [Main content]

            ## Conclusion
            [Summarize key takeaways and call to action]

            ---
            *Variables: TOPIC, AUDIENCE, TONE, WORD_COUNT, SECTION_1_TITLE, SECTION_2_TITLE*
            """,
            type: .template,
            folder: folderPrompts,
            tags: [tagGPT4, tagClaude]
        )

        let a6 = Asset(
            title: "Python Tool-Calling Skill",
            content: """
            import json
            from typing import Any

            def call_tool(tool_name: str, arguments: dict[str, Any]) -> str:
                \"\"\"
                Generic tool dispatcher for LLM function calling.
                Maps tool names to Python functions and returns JSON results.
                \"\"\"
                registry = {
                    "search_web": search_web,
                    "read_file": read_file,
                    "write_file": write_file,
                }
                if tool_name not in registry:
                    return json.dumps({"error": f"Unknown tool: {tool_name}"})
                try:
                    result = registry[tool_name](**arguments)
                    return json.dumps({"result": result})
                except Exception as e:
                    return json.dumps({"error": str(e)})
            """,
            type: .skill,
            folder: folderAgents,
            tags: [tagPython],
            metadata: ["language": "python", "version": "3.11"]
        )

        let a7 = Asset(
            title: "Research Notes: Mixture of Experts",
            content: """
            # Mixture of Experts (MoE) — Research Notes

            ## Key Papers
            - Shazeer et al. (2017) — "Outrageously Large Neural Networks"
            - Fedus et al. (2022) — "Switch Transformers"
            - Jiang et al. (2024) — "Mixtral of Experts"

            ## Core Idea
            Instead of activating all parameters for every token, MoE models
            route each token to a subset of "expert" FFN layers. This allows
            massive parameter counts with manageable compute.

            ## Key Terms
            - **Router / Gating Network:** Decides which experts handle a token
            - **Top-K routing:** Each token goes to K experts (usually K=2)
            - **Expert capacity:** Max tokens per expert per batch
            - **Load balancing loss:** Prevents expert collapse

            ## Open Questions
            - How to handle expert specialization at inference time?
            - Cross-device expert placement for efficient distributed inference?
            """,
            type: .note,
            folder: folderResearch,
            tags: [tagGPT4]
        )

        context.insert(a1)
        context.insert(a2)
        context.insert(a3)
        context.insert(a4)
        context.insert(a5)
        context.insert(a6)
        context.insert(a7)

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            print("SeedData: Failed to save — \(error)")
        }
    }

    private static func libraryAlreadySeeded(in context: ModelContext) -> Bool {
        let folders = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        let assets = (try? context.fetch(FetchDescriptor<Asset>())) ?? []
        let tags = (try? context.fetch(FetchDescriptor<Tag>())) ?? []
        return !folders.isEmpty || !assets.isEmpty || !tags.isEmpty
    }

    private static func normalizeLibraryIfNeeded(in context: ModelContext) {
        var didMutate = false

        let folders = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        let groupedFolders = Dictionary(grouping: folders, by: \.name)
        for duplicates in groupedFolders.values where duplicates.count > 1 {
            let sorted = duplicates.sorted { lhs, rhs in
                if lhs.creationDate != rhs.creationDate { return lhs.creationDate < rhs.creationDate }
                return lhs.id.uuidString < rhs.id.uuidString
            }
            guard let keeper = sorted.first else { continue }
            for duplicate in sorted.dropFirst() {
                for asset in duplicate.assets {
                    asset.folder = keeper
                    asset.touch()
                }
                context.delete(duplicate)
                didMutate = true
            }
        }

        let tags = (try? context.fetch(FetchDescriptor<Tag>())) ?? []
        let groupedTags = Dictionary(grouping: tags, by: \.name)
        for duplicates in groupedTags.values where duplicates.count > 1 {
            let sorted = duplicates.sorted { lhs, rhs in
                if lhs.creationDate != rhs.creationDate { return lhs.creationDate < rhs.creationDate }
                return lhs.id.uuidString < rhs.id.uuidString
            }
            guard let keeper = sorted.first else { continue }
            for duplicate in sorted.dropFirst() {
                for asset in duplicate.assets {
                    if !asset.tags.contains(where: { $0.id == keeper.id }) {
                        asset.tags.append(keeper)
                        asset.touch()
                    }
                }
                context.delete(duplicate)
                didMutate = true
            }
        }

        if didMutate {
            do {
                try context.save()
            } catch {
                print("SeedData: Failed to normalize duplicates — \(error)")
            }
        }
    }
}
