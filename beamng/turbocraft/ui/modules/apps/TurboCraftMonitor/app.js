angular.module('beamng.apps').directive('turboCraftMonitor', [function () {
  return {
    template: `
<div class="tc-root">
  <link type="text/css" rel="stylesheet" href="/ui/modules/apps/TurboCraftMonitor/app.css">
  <svg class="tc-digital-ring" viewBox="0 0 220 220" role="img" aria-label="Live digital turbo boost pressure gauge">
    <circle class="tc-ring-shadow" cx="110" cy="110" r="91"></circle>
    <g class="tc-led-scale">
      <line ng-repeat="segment in ledSegments" ng-class="{lit: segmentIsLit($index), target: segmentIsTarget($index)}"
            ng-attr-x1="{{segment.x1}}" ng-attr-y1="{{segment.y1}}"
            ng-attr-x2="{{segment.x2}}" ng-attr-y2="{{segment.y2}}"></line>
    </g>
    <g class="tc-pressure-ticks">
      <g ng-repeat="tick in pressureTicks()">
        <line ng-attr-x1="{{tick.x1}}" ng-attr-y1="{{tick.y1}}" ng-attr-x2="{{tick.x2}}" ng-attr-y2="{{tick.y2}}"></line>
        <text ng-attr-x="{{tick.x}}" ng-attr-y="{{tick.y}}">{{tick.label}}</text>
      </g>
    </g>
    <line class="tc-measured-pointer" x1="110" y1="50" x2="110" y2="28"
          ng-if="hasMeasurement()" ng-style="{transform: 'rotate(' + dialAngle(state.measured_boost_psi) + 'deg)'}"></line>
    <circle class="tc-target-marker" cx="110" cy="13" r="4" ng-if="!state.pulley_controlled"
            ng-attr-transform="rotate({{dialAngle(target)}} 110 110)"></circle>
  </svg>
  <div class="tc-display-head">
    <span>MEASURED</span>
    <span class="tc-live" ng-class="{live: hasMeasurement()}">{{hasMeasurement() ? 'LIVE' : 'WAIT'}}</span>
  </div>
  <div class="tc-signal-warning" ng-class="{fault: !hasMeasurement()}" role="status">{{signalWarning()}}</div>
  <div class="tc-reading" aria-live="polite">
    <strong>{{measured()}}</strong>
    <small>PSI</small>
  </div>
  <div class="tc-setpoint">
    <span class="tc-set-label">{{state.pulley_controlled ? 'PULLEY DRIVE' : boostMode + ' TARGET'}}</span>
    <strong class="tc-set-value">{{state.pulley_controlled ? pulleyText() : num(target)}} <small>{{state.pulley_controlled ? '×' : 'PSI'}}</small></strong>
    <div class="tc-set-adjust">
      <button type="button" ng-click="adjustTarget(-1)" ng-disabled="state.pulley_controlled" aria-label="Lower target boost">−</button>
      <button type="button" ng-click="adjustTarget(1)" ng-disabled="state.pulley_controlled" aria-label="Raise target boost">+</button>
    </div>
  </div>
  <div class="tc-center-controls" aria-label="Set and mode controls">
    <button type="button" class="tc-center-button tc-details" ng-click="toggleDetails()"
            ng-attr-aria-expanded="{{detailsOpen}}"
            ng-attr-aria-label="{{detailsOpen ? 'Hide target range and diagnostics' : 'Set target range and show diagnostics'}}"
            title="SET">SET</button>
    <button type="button" class="tc-center-button tc-record" ng-click="nextMode()" ng-disabled="state.pulley_controlled"
            ng-attr-aria-label="Switch boost mode, currently {{boostMode}}"
            title="MODE">MODE</button>
  </div>
  <section class="tc-details-panel" ng-if="detailsOpen" aria-label="Boost diagnostics">
    <div class="tc-details-head">
      <strong>BOOST MODE SETTINGS</strong>
      <button type="button" ng-click="toggleDetails()" aria-label="Close diagnostics">×</button>
    </div>
    <div class="tc-mode-setting" ng-repeat="mode in boostModes">
      <label>{{mode}} <span>{{num(targets[mode])}} PSI</span></label>
      <input type="range" min="0" max="200" step="1" ng-model="targets[mode]" ng-disabled="state.pulley_controlled"
             ng-change="modeTargetChanged(mode)" ng-attr-aria-label="{{mode}} target boost">
    </div>
    <div class="tc-panel-label">LIVE SETUP</div>
    <div class="tc-grid">
      <span>RPM</span><b>{{num(state.rpm)}}</b>
      <span>Setup</span><b>{{sizeText()}}</b>
      <span>Control</span><b ng-class="{ok: (state.control_or_wastegate || '').indexOf('applied') === 0}">{{controlText()}}</b>
      <span>Signal</span><b>{{shortText(state.signal_source, 'None')}}</b>
      <span>Pressure</span><b>{{shortText(state.measurement_kind, 'Unavailable')}}</b>
      <span>Vacuum</span><b>{{state.vacuum_available ? 'Available' : 'NOT AVAILABLE'}}</b>
      <span>Ambient</span><b>{{shortText(state.ambient_source, 'Unavailable')}}</b>
    </div>
    <div class="tc-panel-label">SOUND & FLAMES</div>
    <div class="tc-grid">
      <span>Tailpipes</span><b>{{state.afterfire_endpoint_count == null ? '—' : num(state.afterfire_endpoint_count)}}</b>
      <span>Flames</span><b>{{shortText(state.afterfire_routing_status, 'Factory')}}</b>
      <span>Limiter</span><b>{{shortText(state.limiter_effects_status, 'Idle')}}</b>
      <span>Induction</span><b>{{shortText(state.original_audio_status, 'Disabled')}}</b>
      <span>Gearbox</span><b>{{shortText(state.shift_audio_profile, 'Not detected')}}</b>
      <span>Shift sound</span><b>{{shiftAudioStatusText()}}</b>
    </div>
    <div class="tc-panel-label">SYSTEM</div>
    <div class="tc-grid">
      <span>Status</span><b ng-class="{ok: state.valid}">{{statusText()}}</b>
      <span>Logger</span><b ng-class="{ok: state.logger.active}">{{loggerText()}}</b>
    </div>
    <button type="button" class="tc-logger-toggle" ng-click="toggleLogger()">
      {{state.logger.active ? 'Stop log' : 'Start log'}}
    </button>
  </section>
</div>`,
    replace: true,
    restrict: 'EA',
    scope: true,
    link: function (scope) {
      scope.state = {target_boost_psi: 8, valid: false, logger: {active: false, sampleCount: 0}}
      scope.target = 8
      scope.boostModes = ['LOW', 'MED', 'HIGH']
      scope.boostMode = 'MED'
      scope.targets = {LOW: 8, MED: 8, HIGH: 30}
      scope.detailsOpen = false
      let lastSampleAt = null
      let shrinkSince = null
      scope.scaleMax = 20
      scope.num = value => Number.isFinite(Number(value)) ? Math.round(Number(value) * 10) / 10 : 0
      scope.hasMeasurement = () => {
        const value = scope.state.measured_boost_psi
        return scope.state.valid && value !== null && value !== undefined && value !== ''
          && Number.isFinite(Number(value))
      }
      scope.measured = () => {
        const value = scope.state.measured_boost_psi
        return scope.hasMeasurement()
          ? scope.num(value)
          : '—'
      }
      scope.signalWarning = () => !scope.hasMeasurement()
        ? (scope.state.error_flags === 'telemetry_stale' ? 'SIGNAL LOST' : 'NO PRESSURE SIGNAL')
        : (!scope.state.vacuum_available ? 'BOOST ONLY · VACUUM N/A'
          : (Number(scope.state.measured_boost_psi) < 0 ? 'VACUUM' : 'MANIFOLD BOOST'))
      const requiredMax = () => {
        let required = scope.state.pulley_controlled ? 0 : Math.max(0, Number(scope.target) || 0)
        const measured = Number(scope.state.measured_boost_psi)
        if (scope.state.valid && Number.isFinite(measured)) required = Math.max(required, measured)
        if (required <= 20) return 20
        if (required <= 40) return 40
        if (required <= 60) return 60
        if (required <= 80) return 80
        if (required <= 100) return 100
        if (required <= 150) return 150
        if (required <= 200) return 200
        return Math.ceil(required / 50) * 50
      }
      scope.dialMax = () => Math.max(scope.scaleMax, requiredMax())
      scope.dialAngle = value => {
        const max = scope.dialMax()
        const number = Number(value)
        const clamped = Number.isFinite(number) ? Math.max(-15, Math.min(max, number)) : -15
        return clamped <= 0 ? 225 + (clamped + 15) * 4 : 285 + clamped / max * 210
      }
      let tickMax, tickCache
      scope.pressureTicks = () => {
        const max = scope.dialMax()
        if (tickMax === max) return tickCache
        tickMax = max
        tickCache = [-15, 0, max / 4, max / 2, max * 3 / 4, max].map(value => {
        const angle = (scope.dialAngle(value) - 90) * Math.PI / 180
        const x = Math.cos(angle), y = Math.sin(angle)
        return {label: Math.round(value), x1: 110 + x * 75, y1: 110 + y * 75,
          x2: 110 + x * 89, y2: 110 + y * 89, x: 110 + x * 99, y: 113 + y * 99}
        })
        return tickCache
      }
      scope.ledSegments = Array.from({length: 40}, (_, index) => {
        const angle = (135 + (index + 0.5) * 270 / 40) * Math.PI / 180
        const x = Math.cos(angle)
        const y = Math.sin(angle)
        return {
          x1: (110 + x * 78).toFixed(2),
          y1: (110 + y * 78).toFixed(2),
          x2: (110 + x * 87).toFixed(2),
          y2: (110 + y * 87).toFixed(2)
        }
      })
      scope.segmentIsLit = index => {
        if (!scope.hasMeasurement()) return false
        const value = scope.state.measured_boost_psi
        if (value === null || value === undefined || value === '') return false
        const measured = Number(value)
        if (!Number.isFinite(measured)) return false
        const ratio = (scope.dialAngle(measured) - 225) / 270
        return index < Math.ceil(ratio * scope.ledSegments.length)
      }
      scope.segmentIsTarget = index => {
        if (scope.state.pulley_controlled) return false
        const ratio = (scope.dialAngle(scope.target) - 225) / 270
        return index === Math.round(ratio * (scope.ledSegments.length - 1))
      }
      scope.shortText = (value, fallback) => String(value || fallback).replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
      scope.shiftAudioStatusText = () => ({
        shift_audio_profile_ready: 'Ready · awaiting shift',
        shift_audio_generic_ready: 'Generic gear cue ready',
        shift_audio_play_call_issued_1: 'SFX call sent · 1 exhaust end',
        shift_audio_play_call_issued_2: 'SFX call sent · 2 exhaust ends',
        shift_audio_play_call_issued_engine_fallback: 'SFX sent · engine location (no exhaust end)',
        transmission_unclassified: 'Gearbox not detected',
        shift_gear_signal_unavailable: 'Gear signal unavailable',
        shift_skipped_low_or_missing_load: 'Load below 30% or missing',
        shift_audio_api_unavailable: 'SFX API unavailable',
        shift_exhaust_endpoints_unavailable: 'Exhaust ends unavailable',
        native_shift_afterfire_owns_event: 'Native shift event owns sound',
        shift_exhaust_unavailable_or_submerged: 'No dry exhaust end'
      })[scope.state.shift_audio_status] || scope.shortText(scope.state.shift_audio_status, 'Waiting for vehicle')
      scope.controlText = () => {
        const raw = String(scope.state.control_or_wastegate || '')
        if (raw.indexOf('applied') === 0) return 'Active'
        if (raw.indexOf('waiting') >= 0) return 'Waiting'
        return scope.shortText(raw, 'N/A')
      }
      scope.pulleyText = () => scope.state.pulley_drive_ratio != null
        && scope.state.pulley_drive_ratio !== '' && Number.isFinite(Number(scope.state.pulley_drive_ratio))
        ? Number(scope.state.pulley_drive_ratio).toFixed(2) : '—'
      scope.statusText = () => scope.shortText(scope.state.error_flags, scope.hasMeasurement() ? 'Ready' : 'Waiting for boost signal')
      scope.loggerText = () => scope.state.logger.writeError ? `ERROR · ${scope.state.logger.writeError}` : scope.state.logger.active
        ? `Recording · ${scope.num(scope.state.logger.sampleCount)} samples`
        : 'Stopped'
      scope.toggleDetails = () => { scope.detailsOpen = !scope.detailsOpen }
      scope.sizeText = () => {
        const s = scope.state
        if (s.kit_model) return s.kit_model
        if (s.turbo_size_mm == null || !Number.isFinite(Number(s.turbo_size_mm))) return 'Select TC intake'
        const ar = value => Number.isFinite(Number(value)) ? Number(value).toFixed(2) : '?'
        const bov = {atmospheric: 'BOV', tuned: 'BOV tuned', recirculating: 'BPV', none: 'no BOV'}[s.bov_type] || ''
        return `${Number(s.turbo_size_mm).toFixed(0)} mm · C ${ar(s.compressor_cover_ar)} · T ${ar(s.turbine_housing_ar)}${bov ? ' · ' + bov : ''}`
      }
      const targetTimers = {}
      const sendTarget = (mode, value) => {
        if (scope.state.pulley_controlled) return
        clearTimeout(targetTimers[mode])
        targetTimers[mode] = setTimeout(() => bngApi.engineLua(`extensions.load("turbocraftUI"); turbocraftUI.setBoostTarget("${mode}", ${value})`), 80)
      }
      scope.targetChanged = () => {
        const value = Math.max(0, Math.min(200, Number(scope.target) || 0))
        scope.target = value
        const mode = scope.boostMode
        scope.targets[mode] = value
        sendTarget(mode, value)
      }
      scope.modeTargetChanged = mode => {
        const value = Math.max(0, Math.min(200, Number(scope.targets[mode]) || 0))
        scope.targets[mode] = value
        if (mode === scope.boostMode) scope.target = value
        sendTarget(mode, value)
      }
      scope.adjustTarget = delta => {
        if (scope.state.pulley_controlled) return
        scope.target = Math.max(0, Math.min(200, (Number(scope.target) || 0) + delta))
        scope.targetChanged()
      }
      scope.nextMode = () => { if (!scope.state.pulley_controlled) bngApi.engineLua('extensions.load("turbocraftUI"); turbocraftUI.nextBoostMode()') }
      scope.toggleLogger = () => bngApi.engineLua('extensions.load("turbocraftUI"); turbocraftUI.toggleLogger()')
      scope.$on('TurboCraftState', (event, state) => scope.$evalAsync(() => {
        if (!state) return
        lastSampleAt = state.valid ? Date.now() : null
        state.logger = state.logger || {active: false, sampleCount: 0}
        scope.state = state
        scope.boostMode = state.boost_mode || 'MED'
        if (!document.activeElement || document.activeElement.type !== 'range') {
          scope.target = Number(state.target_boost_psi) || 0
          scope.targets = Object.assign({}, scope.targets, state.boost_targets || {})
        }
        const required = requiredMax()
        if (required >= scope.scaleMax) {
          scope.scaleMax = required
          shrinkSince = null
        } else if (required < scope.scaleMax * 0.65) {
          if (shrinkSince === null) shrinkSince = Date.now()
          if (Date.now() - shrinkSince >= 2000) scope.scaleMax = required
        } else shrinkSince = null
      }))
      const staleTimer = setInterval(() => {
        if (lastSampleAt !== null && Date.now() - lastSampleAt > 500) {
          lastSampleAt = null
          scope.$evalAsync(() => {
            scope.state.valid = false
            scope.state.measured_boost_psi = null
            scope.state.error_flags = 'telemetry_stale'
          })
        }
      }, 100)
      scope.$on('$destroy', () => {
        clearInterval(staleTimer)
        Object.keys(targetTimers).forEach(mode => clearTimeout(targetTimers[mode]))
      })
      bngApi.engineLua('extensions.load("turbocraftUI"); turbocraftUI.requestState()')
    }
  }
}])
