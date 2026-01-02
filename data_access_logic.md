# Data Access Logic — NotNaked PIM

This document describes the pseudo-code for accessing and manipulating product data
within the NotNaked Product Information Management (PIM) system.  
The logic follows **UDM principles**, is **variant-first**, and is designed for execution
within the **Moqui Framework**.

---

## Design Goals

- SKU is the primary operational identifier
- Product ingestion is idempotent and safe to re-run
- Variants, pricing, attributes, and images are handled independently
- All deletions are soft deletes
- External IDs are authoritative for Shopify synchronization

---

## Service: createOrUpdateProductFromShopify

**Purpose:**  
Ingest a Shopify product payload and create or update product, variants, pricing,
attributes, and images.

### Parameters
- shopifyProductPayload

### Logic
1. Validate payload:
   - product.id must be present
   - variants array must not be empty
2. Attempt to find existing Product using:
   - product_identification_type_id = SHOPIFY_PRODUCT_ID
3. If Product does not exist:
   - Generate new productId
   - Create Product record:
     - product_name = title
     - description = body_html
     - product_type = product_type
     - vendor = vendor
     - status_id = ACTIVE
     - from_date = now()
   - Create ProductIdentification (SHOPIFY_PRODUCT_ID)
4. If Product exists:
   - Update Product core fields
5. Process product options:
   - For each option in payload.options:
     - Upsert ProductOption
     - Upsert ProductOptionValue records
6. Process variants:
   - For each variant in payload.variants:
     - Validate SKU uniqueness
     - Upsert ProductVariant using SKU
     - Upsert ProductIdentification (SHOPIFY_VARIANT_ID)
     - Map variant to option values
     - Upsert ProductPrice:
       - LIST_PRICE
       - SALE_PRICE (if present)
7. Process images:
   - Upsert ProductImage records
8. Return success with productId

---

## Service: getProductBySku

**Purpose:**  
Retrieve full product information using SKU.

### Parameters
- sku

### Logic
1. Find ProductVariant by SKU
2. If not found, return error
3. Fetch associated Product
4. Fetch active ProductPrice records
5. Fetch ProductOption and ProductOptionValue mappings
6. Fetch ProductImage records
7. Aggregate and return product, variant, pricing, attributes, and images

---

## Service: getProductById

**Purpose:**  
Retrieve product and all variants using productId.

### Parameters
- productId

### Logic
1. Validate Product exists
2. Fetch all active ProductVariants
3. For each variant:
   - Fetch pricing
   - Fetch option mappings
4. Fetch ProductImage records
5. Aggregate and return result

---

## Service: updateProduct

**Purpose:**  
Update product metadata, variants, pricing, and attributes.

### Parameters
- productId
- productUpdateMap

### Logic
1. Validate Product exists
2. Update Product core fields if present
3. Process variant updates:
   - Match variants using SKU
   - Update variant attributes or status
4. Process pricing updates:
   - Expire existing ProductPrice records (thru_date = now)
   - Insert new ProductPrice records
5. Process attribute updates:
   - Update ProductOption and ProductOptionValue records
   - Re-map variant associations
6. Return success

---

## Service: archiveProduct

**Purpose:**  
Soft-delete a product while preserving historical data.

### Parameters
- productId

### Logic
1. Validate Product exists
2. Set product.status_id = ARCHIVED
3. Set thru_date = now() on:
   - Product
   - ProductVariants
   - ProductPrices
   - ProductCategoryMember
4. Do not physically delete records
5. Return success message

---

## Notes

- SKU uniqueness is enforced at the ProductVariant level
- Shopify identifiers are stored exclusively in product_identification
- All updates are idempotent and safe for reprocessing
- Pricing and categorization support temporal tracking
- No hard deletes are performed

---
