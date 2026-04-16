---
name: exa-search
description: Search the web using Exa's semantic search engine. Use this when you need to find current information, news, research papers, companies, people, or any web content.
---

# exa-search

## Purpose
Search the web using Exa's neural/semantic search. Returns titles, URLs, published dates, and optional content from matching pages.

## Cost Awareness
Exa charges per search AND per page of content retrieved. Keep costs down:
- **Default behavior returns URLs and metadata only — no content cost**
- **Use `highlights: true` as your first choice for content** — cheapest way to get relevant excerpts
- **Use `summary: true` when scanning many results** — one sentence per page, low cost
- **Avoid `text: true` unless you genuinely need full page content** — most expensive option
- **Keep `num_results` low** — you can always search again. More results = more cost
- **`subpages` and `image_links` default to 0** — only increase if specifically needed
- `deep` and `deep-reasoning` search types cost significantly more than `auto` or `neural` — reserve for serious research tasks

## Parameters

- `query` (required): The search query string
- `search_type` (optional): Search mode — `auto` (default), `neural`, `fast`, `deep`, `deep-reasoning`, `instant`. Use `auto` unless you have a specific reason
- `num_results` (optional): Number of results. **Currently locked at 10.** Parameter kept for future use
- `category` (optional): Focus on a content type — `news`, `research paper`, `tweet`, `company`, `people`, `personal site`, `financial report`. Use this to narrow results cheaply before retrieving content
- `start_published_date` (optional): Only return results published after this date. ISO 8601 format e.g. `2025-01-01T00:00:00.000Z`
- `end_published_date` (optional): Only return results published before this date. ISO 8601 format
- `include_domains` (optional): Comma-separated domains to restrict results to e.g. `github.com,arxiv.org`. Use this to avoid noise
- `exclude_domains` (optional): Comma-separated domains to exclude
- `include_text` (optional): Word or short phrase (max 5 words) that must appear in results
- `exclude_text` (optional): Word or short phrase (max 5 words) that must NOT appear in results
- `user_location` (optional): Two-letter ISO country code e.g. `US`
- `highlights` (optional): Return relevant excerpts. Boolean, default false. **Prefer this over `text`**
- `summary` (optional): Return a one-sentence summary per result. Boolean, default false. Good for scanning
- `text` (optional): Return full page text. Boolean, default false. **Expensive — avoid unless necessary**
- `image_links` (optional): Number of image links per result. Default 0, leave at 0 unless needed
- `subpages` (optional): Number of subpages to crawl per result. Default 0, leave at 0 unless needed
- `livecrawl` (optional): `always`, `fallback` (default), `never`. Leave as fallback unless you specifically need live content

## Recommended Patterns

**Quick research** — metadata only, no content cost:
```json
{ "query": "n8n workflow automation 2025", "category": "news" }
```

**Read the good stuff** — highlights on relevant results:
```json
{ "query": "pgvector hybrid search tutorial", "highlights": true, "include_domains": "github.com,dev.to" }
```

**Stay current** — recent news only:
```json
{ "query": "Claude API updates", "category": "news", "start_published_date": "2025-01-01T00:00:00.000Z", "summary": true }
```

## Edge Cases
- `category: people` only supports `include_domains` with LinkedIn domains
- `category: company` and `category: people` do not support date filters or include/exclude text
- `deep` and `deep-reasoning` ignore some filters — check results carefully

specs:
```json
{
  "query": {
    "description": "The search query string",
    "type": "string",
    "required": true
  },
  "search_type": {
    "description": "Search mode: auto (default), neural, fast, deep, deep-reasoning, instant. Use auto unless you have a specific reason",
    "type": "string",
    "required": false
  },
  "num_results": {
    "description": "Number of results. Currently locked at 10 — parameter kept for future use",
    "type": "number",
    "required": false
  },
  "category": {
    "description": "Content category: news, research paper, tweet, company, people, personal site, financial report",
    "type": "string",
    "required": false
  },
  "start_published_date": {
    "description": "Return results published after this date. ISO 8601 e.g. 2025-01-01T00:00:00.000Z",
    "type": "string",
    "required": false
  },
  "end_published_date": {
    "description": "Return results published before this date. ISO 8601 format",
    "type": "string",
    "required": false
  },
  "include_domains": {
    "description": "Comma-separated domains to restrict results to e.g. github.com,arxiv.org",
    "type": "string",
    "required": false
  },
  "exclude_domains": {
    "description": "Comma-separated domains to exclude",
    "type": "string",
    "required": false
  },
  "include_text": {
    "description": "Word or short phrase (max 5 words) that must appear in results",
    "type": "string",
    "required": false
  },
  "exclude_text": {
    "description": "Word or short phrase (max 5 words) that must NOT appear in results",
    "type": "string",
    "required": false
  },
  "user_location": {
    "description": "Two-letter ISO country code e.g. US",
    "type": "string",
    "required": false
  },
  "highlights": {
    "description": "Return relevant excerpts. Preferred content option — cheap and effective",
    "type": "boolean",
    "required": false
  },
  "summary": {
    "description": "Return a one-sentence summary per result. Good for scanning many results cheaply",
    "type": "boolean",
    "required": false
  },
  "text": {
    "description": "Return full page text. Most expensive option — avoid unless full content is genuinely needed",
    "type": "boolean",
    "required": false
  },
  "image_links": {
    "description": "Number of image links per result. Default 0 — only increase if specifically needed",
    "type": "number",
    "required": false
  },
  "subpages": {
    "description": "Number of subpages to crawl per result. Default 0 — only increase if specifically needed",
    "type": "number",
    "required": false
  },
  "livecrawl": {
    "description": "Live-crawl for fresh content: always, fallback (default), never",
    "type": "string",
    "required": false
  }
}
```