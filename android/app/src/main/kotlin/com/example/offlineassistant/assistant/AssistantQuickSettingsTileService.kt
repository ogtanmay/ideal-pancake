package com.example.offlineassistant.assistant

import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class AssistantQuickSettingsTileService : TileService() {
    private var active = false

    override fun onClick() {
        super.onClick()
        active = !active
        qsTile?.state = if (active) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        qsTile?.updateTile()
    }
}
