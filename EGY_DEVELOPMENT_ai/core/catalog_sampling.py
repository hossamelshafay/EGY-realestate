"""Bounded discovery samples from the existing catalog."""

import random
from functools import cached_property

RESIDENTIAL = frozenset({
    "Apartment", "Bungalow", "Cabin", "Chalet", "Duplex", "Hotel Apartment",
    "Palace", "Penthouse", "Roof", "Townhouse", "Twin House", "Villa", "iVilla",
})
COMMERCIAL = frozenset({
    "Bulk Rent Unit", "Bulk Sale Unit", "Cafeteria", "Clinic",
    "Co-Working Space", "Factory", "Farm", "Medical Facility", "Office Space",
    "Restaurant", "Retail", "Shop", "Show Room", "Staff Accommodation",
    "Warehouse",
})
CATEGORIES = {
    "buy": ("Residential - Buy", RESIDENTIAL),
    "rent": ("Residential - Rent", RESIDENTIAL),
    "commercial_buy": ("Commercial - Buy", COMMERCIAL - {"Bulk Rent Unit"}),
    "commercial_rent": ("Commercial - Rent", COMMERCIAL - {"Bulk Sale Unit"}),
}


class CatalogSampler:
    """Filter and index on first use, then draw only the requested cards."""

    def __init__(self, engine):
        self.engine = engine

    @cached_property
    def ids(self):
        data = self.engine.df.drop_duplicates("id", keep=False)
        return {
            code: tuple(map(int, data.loc[
                data["category"].eq(code)
                & data["category_en"].eq(label)
                & data["property_type"].isin(types), "id"
            ]))
            for code, (label, types) in CATEGORIES.items()
        }

    def sample(self, category, limit, excluded):
        pool = self.ids[category]
        excluded = set(excluded)
        available = [pid for pid in pool if pid not in excluded] if excluded else pool
        chosen = random.sample(available, min(limit, len(available)))
        if len(chosen) < limit and excluded:
            fallback = [pid for pid in pool if pid in excluded]
            chosen.extend(random.sample(fallback, min(limit - len(chosen), len(fallback))))
        return [self.engine.get_property(pid) for pid in chosen]
