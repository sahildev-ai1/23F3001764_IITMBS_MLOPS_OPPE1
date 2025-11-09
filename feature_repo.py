from datetime import timedelta
from feast import Entity, Field, FeatureView, FileSource
from feast.types import Float32

feature_source = FileSource(
    path="data/features/current",
    file_format="parquet",
    timestamp_field="event_timestamp",
)

stock = Entity(
    name="stock_name",
    join_keys=["stock_name"],
    description="Stock ticker/name",
)

stock_minute_features = FeatureView(
    name="stock_minute_features",
    entities=[stock],
    ttl=timedelta(days=3650),
    schema=[
        Field(name="rolling_avg_10", dtype=Float32),
        Field(name="volume_sum_10", dtype=Float32),
    ],
    source=feature_source,
    online=True,
)
