# Introduction

**Icon Set Generator Demo** is a Spring Boot-based backend service designed to generate optimized icon sets based on user-provided tags. It efficiently handles icon metadata using PostgreSQL with advanced bitmap indexing (`roaringbitmap`) and integrates with **MinIO** for object storage.

### Key Features
- Dynamic icon set generation based on tag combinations  
- High-performance bitmap operations using RoaringBitmap  
- File upload and storage integration via MinIO  

### Component Interaction
1. The client sends an `IconSetRequest` (with tag IDs, set size, threshold).
2. `IconSetGeneratorService` calls a custom repository method (`generateSetFromTags`) to generate a bitmap-based set.
3. The database executes the function and returns a `setId`.
4. The response is wrapped in an `IconSetResponse` and sent back to the client.
5. If files are uploaded, `MinioService` stores them in a specified bucket.


# API Endpoints

##  1. Icon Upload API

### **POST /api/icons/upload**
Upload an icon with its metadata to corresponding database (postgres + minIO)


**Description:**  
Uploads a single icon along with its metadata (tags, category, etc.).

**Metadata JSON Structure**
```json
{   
 "category": "vehicles",  
 "tags": [{"name": "favorite"}, {"name": "cars"}] 
} 


```

**Response (success) Example:**
```json
{
    "id": 93,
    "name": "vehicles/1759822332856.png",
    "tags": [
        "favorite",
        "cars"
    ],
    "category": "vehicles"
}
```




##  2. Icon Set Generator API

### **POST /api/icon-sets/generate**

Generate a new icon set from provided tags.

**Description:**  
Takes a list of tag IDs, a desired set size, and a threshold.  
Internally calls the PostgreSQL function `generateSetFromTags`.

**Request Body Example:**
```json
{
  "tagIds": [1, 2, 3, 4],
  "setSize": 10,
  "threshold": 0.3
}

```

**Response (success) Example:**
```json
{
  "setId": 101,
  "status": "SUCCESS"
}
```
**Response (failure) Example:**
```json
{
  "setId": null,
  "status": "FAILED_OR_DUPLICATE_OR_OVERLAP"
}
```

# Diagrams

1. Sequence flow: Upload File Scenario 

  ![Upload File Scenario - Sequence Flow Diagram](upload-file.png)

2. Sequence flow: Generate Icon Set

  ![Generate Icon Set - Sequence Flow Diagram](generate-icons-set.png)

3. Entity relationship diagram 

  ![Tables Diagram](diagram-draft2.png)

3. DB Schema 

  ![Tables Diagram](diagram-draft1.png)

# System Constraints and Design Considerations (for the future)
## Minimum Set Size
- **Problem:**
  If the requested set size is too small it will most likely give overlap check error at some point for every incoming request (whose set size is 1,2 for example). To prevent the overlap checking logic to trigger false overlap errors, there must be a constraint to set minimum set size (5 for example)
- **Constraint:**
  The minimum set size must be at least 5 (it can be configurable)
- **Validation Rule:**
  if (setSize < 5 ) then reject the request (400 Bad Request)

## Tag based limitation
- **Problem:**
  When multiple tags are selected for set generation, random sampling might possibly over represent a single tag (for example; user chose tags like bikes, cars, blue.. but when icon set generated, it only randomly picked icons from only car tags omitting the others, because it is random)
- **Constraint:**
  Impose a maximum icon count per tag (e.g., perTagLimit < setSize * 0.5)
- **Validation Rule:**
  Ensuring balanced icon distribution in icon set generation
- **Note (additional feature):**
  It might be possible to add weights field for each tags, so when a user chooses tags in the request, adding weights can be influential in icon distribution

## Icon Usage Control
- **Problem:**
  If one icon is used many times, it will become hot icon and more visible in icon set generations. In current version, there is no possibility to enabdle/disable icons (temporarily) so by default each icon is active.
- **Possible approach:**
  There can be a logic to dynamically change/calculate weights of tags/icons based on usage frequence. 

  


