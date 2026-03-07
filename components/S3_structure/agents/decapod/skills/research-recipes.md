---
name: research-recipes
description: Search for recipes using TheMealDB API. Use this when you need to find recipes by name, ingredient, category, or area/cuisine.
---

# research-recipes

## Purpose
Search for recipes using TheMealDB's free recipe database. Returns recipe names, IDs, thumbnails, and other metadata that can be used to fetch full recipe details.

## Parameters
- `search_type` (required): Type of search to perform. Options: "name", "ingredient", "category", "area", "random"
- `query` (optional): Search query based on search_type. Not needed for "random" searches.
- `max_results` (optional): Maximum number of results to return (default: 10)

## Search Types
- **name**: Search recipes by name (e.g., "pizza", "pasta", "chicken")
- **ingredient**: Find recipes containing a specific ingredient (e.g., "chicken_breast", "tomato")
- **category**: Filter recipes by category (e.g., "Seafood", "Vegetarian", "Dessert")
- **area**: Filter recipes by cuisine/area (e.g., "Italian", "Mexican", "Chinese")
- **random**: Get random recipe suggestions (ignores query parameter)

## Usage Examples

Search for pizza recipes:
```yaml
search_type: name
query: pizza
max_results: 5
```

Find chicken recipes:
```yaml
search_type: ingredient
query: chicken_breast
max_results: 10
```

Get Italian recipes:
```yaml
search_type: area
query: Italian
max_results: 8
```

Get random recipe inspiration:
```yaml
search_type: random
max_results: 3
```

## Expected Output
Returns a list of recipes with:
- Recipe name
- Recipe ID (for fetching full details later)
- Thumbnail image URL
- Category
- Area/cuisine
- Brief description (when available)

## Edge Cases
- If no recipes match the query, returns empty results with helpful message
- For ingredient searches, use underscores instead of spaces (e.g., "chicken_breast" not "chicken breast")
- Random searches ignore the query parameter
- max_results is capped at 20 to avoid overwhelming responses

## Notes
- Uses free TheMealDB API (test key: "1")
- Results are cached for performance
- For full recipe details (ingredients, instructions), use the returned recipe ID with a separate lookup

specs:
```json
{
  "search_type": {
    "description": "Type of search - \"name\", \"ingredient\", \"category\", \"area\", or \"random\"",
    "type": "string",
    "required": true
  },
  "query": {
    "description": "Search query (not needed for random searches)",
    "type": "string",
    "required": false
  },
  "max_results": {
    "description": "Maximum number of results to return (default 10, max 20)",
    "type": "number",
    "required": false
  }
}
```