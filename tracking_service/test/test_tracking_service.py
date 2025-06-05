from datetime import datetime
from unittest.mock import MagicMock, patch

import pytest

from tracking_service.app.schemas.tracking_schemas import (
    TrackingEventCreate, TrackingEventOut, TrackingHistoryOut)
from tracking_service.app.services.tracking_service import TrackingService


@pytest.fixture
def service():
    return TrackingService()


def test_add_tracking_event(service):
    data = TrackingEventCreate(
        tracking_code="TRK123", status="shipped", timestamp=datetime.now()
    )

    # 🔧 FIX: Patch donde se usa, no donde se define
    with patch(
        "tracking_service.app.services.tracking_service.save_tracking_event"
    ) as mock_save:
        response = service.add_tracking_event(data)
        mock_save.assert_called_once()
        assert response == {"message": "Tracking event recorded"}


def test_get_history(service):
    mock_event = MagicMock()
    mock_event.tracking_code = "TRK123"
    mock_event.status = "in_transit"  # ✅ Debe coincidir con lo que se valida
    mock_event.timestamp = datetime.now()

    # 🔧 FIX: Patch donde se usa
    with patch(
        "tracking_service.app.services.tracking_service.get_tracking_events_by_code",
        return_value=[mock_event],
    ):
        history = service.get_history("TRK123")
        assert isinstance(history, TrackingHistoryOut)
        assert history.tracking_code == "TRK123"
        assert isinstance(history.history, list)
        assert isinstance(history.history[0], TrackingEventOut)
        assert history.history[0].status == "in_transit"
