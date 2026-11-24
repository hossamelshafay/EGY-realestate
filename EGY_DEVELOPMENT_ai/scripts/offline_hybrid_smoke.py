"""Real catalog/artifact recommendation smoke test; no provider calls."""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from core.recommendation_engine import recommendation_engine as engine

assert engine.df is not None and len(engine.df) > 0
assert engine.feature_matrix is not None, "Missing/unloaded feature_matrix.npz"
assert engine.top_indices is not None, "Missing/unloaded top_indices.npy"
assert engine.top_scores is not None, "Missing/unloaded top_scores.npy"
assert engine.top_indices.shape == engine.top_scores.shape
assert engine.feature_matrix.shape[0] == engine.top_indices.shape[0]
assert len(engine.id_to_cbf_idx) == engine.feature_matrix.shape[0]
property_id = next(int(pid) for pid in engine.df['id'] if int(pid) in engine.id_to_cbf_idx)
result = engine.recommend_similar(property_id, top_n=6)
assert result.items, "No recommendations returned"
assert all(item.id != property_id for item in result.items)
assert len({item.id for item in result.items}) == len(result.items)
assert all(item.cluster == result.cluster for item in result.items)
print(json.dumps({"catalog_rows": len(engine.df),
                  "matrix_shape": list(engine.feature_matrix.shape),
                  "neighbors_shape": list(engine.top_indices.shape),
                  "result": result.model_dump(),
                  "note": "Similarity is not calibrated confidence"}, indent=2))
