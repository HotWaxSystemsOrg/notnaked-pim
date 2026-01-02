# Shopify Product → NotNaked PIM Mapping

## 1. Overview

This document describes the mapping between product data retrieved from the
**Shopify Product API** and NotNaked’s **UDM-compliant Product Information Management (PIM)** system.

The goal of this mapping is to ensure that Shopify product data is:
- Stored in a normalized, variant-first structure
- Safe for repeated ingestion (idempotent)
- Extensible beyond Shopify
- Aligned with enterprise PIM and UDM principles

---

## 2. High-Level Mapping Strategy

Each Shopify **Product** is modeled as a logical container, while each Shopify
**Variant** is modeled as a sellable unit (SKU).

| Shopify Concept | PIM Representation |
|----------------|--------------------|
| Product | product |
| Variant | product_variant |
| SKU | product_variant.sku |
| Options | product_option / product_option_value |
| Prices | product_price |
| Images | product_image |
| External IDs | product_identification |

---

## 3. Core Product Field Mapping

### Shopify Product → PIM Product

| Shopify Field | Type | PIM Table | PIM Column | Notes |
|--------------|------|-----------|-----------|-------|
| id | number | product_identification | id_value | identification_type = SHOPIFY_PRODUCT_ID |
| title | string | product | product_name | Direct mapping |
| body_html | string | product | description | Stored as HTML |
| product_type | string | product | product_type | Used for classification |
| vendor | string | product | vendor | Direct mapping |
| status | string | product | status_id | active → ACTIVE |
| created_at | datetime | product | from_date | Converted to DATE |

---

## 4. Variant Mapping

Shopify variants represent the true sellable items.

| Shopify Field | PIM Table | PIM Column | Notes |
|--------------|-----------|-----------|-------|
| id | product_identification | id_value | identification_type = SHOPIFY_VARIANT_ID |
| sku | product_variant | sku | Must be unique |
| barcode | product_variant | barcode | UPC / GTIN |
| created_at | product_variant | from_date | Converted to DATE |

---

## 5. Pricing Mapping

| Shopify Field | PIM Table | Mapping |
|--------------|-----------|---------|
| price | product_price | LIST_PRICE |
| compare_at_price | product_price | COMPARE_AT_PRICE |
| currency | product_price | Store currency |

Rules:
- Prices are variant-level
- Old prices are expired via thru_date

---

## 6. Options & Attributes Mapping

| Shopify Field | PIM Table |
|--------------|-----------|
| options[].name | product_option |
| options[].values | product_option_value |
| variant.option1/2/3 | product_variant_option |

---

## 7. Image Mapping

| Shopify Field | PIM Table | PIM Column |
|--------------|-----------|-----------|
| images[].src | product_image | image_url |
| images[].position | product_image | position |

---

## 8. Data Transformation Rules

- Shopify IDs are stored only as external identifiers
- SKU uniqueness enforced at variant level
- DateTime → DATE conversion
- Missing fields stored as NULL

---

## 9. Duplicate Handling

- Match on SHOPIFY_PRODUCT_ID
- Match on SHOPIFY_VARIANT_ID
- Validate SKU consistency

---

## 10. Example Transformation

Shopify product with 1 variant →
- Product
- ProductVariant (SKU)
- ProductPrice
- ProductOption mappings

---

## 11. Summary

This mapping preserves Shopify semantics while maintaining a clean,
UDM-compliant, enterprise-grade PIM model.
