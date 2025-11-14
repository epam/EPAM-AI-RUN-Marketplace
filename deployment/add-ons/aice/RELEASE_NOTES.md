# AICE Platform – Initial Deployment Release Notes
 
Version: 0.1.0
Release Date: 2025-11-05
Status: Internal Early Access (Foundational)
 
---
## 1. Executive Summary
AICE (AI Code Exploration) delivers its initial set of foundational capabilities for intelligent, multi‑language code understanding inside the AI/Run Codemie Platform. This first release lets users create exploration workspaces, index one or more repositories, navigate structural and functional views, inspect dependencies, and leverage AI‑generated summaries. Access is provided through Codemie Apps (UI) and SPI data sources, establishing a base for future automated refactoring, architecture intelligence and cross‑repository insights.
 
---
## 2. Release Highlights
Core user‑facing functionality included in 0.1.0:
 
| Area | Delivered Capability |
|------|----------------------|
| Codemie Integration | SPI descriptor driven data sources + embeddable App experience |
| Workspace Management | Create, list and manage code exploration workspaces directly in the AICE UI |
| Multi‑Language Indexing | Java, C++, C#, JS, TS repository parsing and graph construction |
| Structural Views | Code Structure, Component Structure and Feature Structure navigation layers |
| Search | Full‑text and vector search across indexed code elements and AI-generated summaries |
| Conversational Assistant | Natural language queries with adaptive strategies: Q&A and Batch via AI Tasks |
 
 
---
## 3. Codemie Platform Integration
This release provides seamless integration through two primary surfaces:
 
1. **SPI Data Sources** – AICE exposes two toolkit via Codemie’s Service Provider Interface:
  - Code Analysis Toolkit: file‑level and member‑level operations on parsed source code
  - Code Exploration Toolkit: graph‑oriented operations (nodes, relationships, Cypher queries, enriched metadata)
  Both can be attached to Codemie Assistants like any other datasources.
 
2. **Codemie App (AICE UI)** – An interactive web application embedded in Codemie delivering workspace creation, graph navigation, feature/domain exploration, search and chat assistant workflows.
 
Together these surfaces allow both programmatic assistant workflows and rich human exploration to use the same underlying knowledge graph without duplicate integration effort.
 
---
## 4. End‑User Feature Summary
Bullet overview for quick consumption:
- Create & manage exploration workspaces (single or multi‑repository)
- Generate and browse a unified Knowledge Graph with layered abstraction
- Switch between Code, Component and Feature structure views
- Run full‑text and semantic (vector) searches with filtering by code elements, component types
- Inspect class/function dependencies and invocation chains
- Read AI‑generated summaries of components, packages and features
- Use the conversational assistant for direct, contextual or batch analysis
 
---
## 5. Changelog (Initial)
| Type | Item |
|------|------|
| Feature | Workspace creation & management UI |
| Feature | Multi‑language indexing (Java, C++, C#, JS, TS) |
| Feature | Code / Component / Feature structure views |
| Feature | Full‑text & vector search with filtering |
| Feature | AI summarization (bottom‑up) and categorization pipelines |
| Feature | Dependency & Integrations inspection |
| Feature | Conversational assistant (adaptive workflows) |
| Feature | SPI data sources (Code Analysis + Code Exploration Toolkits) |
| Feature | Codemie App embedding |
 
---
## 6. Getting Started
For onboarding, refer to the internal knowledge base guide:
https://kb.epam.com/pages/viewpage.action?pageId=2431790933
 
---
## 7. Future Enhancements (Roadmap Snippet)
Non‑binding areas of planned evolution:
- Feature Structure drill‑down with invocation path tracing
- Chat assistant responsiveness & contextual memory improvements
- Architectural visualization (C4 inspired overlays)
- Cross‑repository integration mapping (runtime/service links)
- Expanded MCP tooling & IDE ecosystem coverage
 
---
## 8. Support & Contact
| Area | Contact Channel |
|------|-----------------|
| Platform & SPI Integration | Codemie / AICE Integration Team |
| Code Analysis & Knowledge Graph Construction | AICE Code Analysis Team |
| AI Assistant | AICE LLM Team |
| UI & User Experience | AICE UX Team |
 
---
**End of Release Notes – AICE 0.1.0**