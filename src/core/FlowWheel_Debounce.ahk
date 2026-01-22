; ============================================================================
; FLOWWHEEL CORE ENGINE - DEBOUNCE MANAGER
; ============================================================================

class DebounceManager {
    static lastCalls := Map()
    
    ; Check if an action can be executed based on debounce time
    static CanExecute(actionName, debounceMs) {
        now := A_TickCount
        
        ; If first call or enough time has passed
        if !this.lastCalls.Has(actionName) {
            this.lastCalls[actionName] := now
            return true
        }
        
        if (now - this.lastCalls[actionName] >= debounceMs) {
            this.lastCalls[actionName] := now
            return true
        }
        
        return false
    }
    
    ; Reset debounce timer for a specific action
    static Reset(actionName) {
        if this.lastCalls.Has(actionName)
            this.lastCalls.Delete(actionName)
    }
    
    ; Reset all debounce timers
    static ResetAll() {
        this.lastCalls.Clear()
    }
}

