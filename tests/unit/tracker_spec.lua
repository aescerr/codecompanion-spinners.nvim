local tracker = require("codecompanion._extensions.spinner.tracker")

describe("Tracker Module", function()
  before_each(function()
    -- Reset tracker state before each test
    tracker.reset()
    tracker.setup(function() end) -- Setup with dummy callback
  end)

  describe("Initial State", function()
    it("should start in IDLE state", function()
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should have valid state constants", function()
      assert.is_number(tracker.State.IDLE)
      assert.is_number(tracker.State.THINKING)
      assert.is_number(tracker.State.RECEIVING)
      assert.is_number(tracker.State.TOOLS_RUNNING)
      assert.is_number(tracker.State.TOOLS_PROCESSING)
      assert.is_number(tracker.State.DIFF_AWAITING)
    end)
  end)

  describe("Request State Transitions", function()
    it("should transition to THINKING on request started", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      assert.equals(tracker.State.THINKING, tracker.get_current_state())
    end)

    it("should transition to RECEIVING on request streaming", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      tracker.handle_event({match = "CodeCompanionRequestStreaming"})
      assert.equals(tracker.State.RECEIVING, tracker.get_current_state())
    end)

    it("should return to IDLE on request finished", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      tracker.handle_event({match = "CodeCompanionRequestStreaming"})
      tracker.handle_event({match = "CodeCompanionRequestFinished"})
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should handle request finished without streaming", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      tracker.handle_event({match = "CodeCompanionRequestFinished"})
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Tool State Transitions", function()
    it("should transition to TOOLS_RUNNING on tool started", function()
      tracker.handle_event({match = "CodeCompanionToolStarted"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())
    end)

    it("should transition to TOOLS_PROCESSING on tool finished", function()
      tracker.handle_event({match = "CodeCompanionToolStarted"})
      tracker.handle_event({match = "CodeCompanionToolFinished"})
      assert.equals(tracker.State.TOOLS_PROCESSING, tracker.get_current_state())
    end)

    it("should return to IDLE on tools finished", function()
      tracker.handle_event("CodeCompanionToolStarted")
      tracker.handle_event("CodeCompanionToolFinished")
      tracker.handle_event("CodeCompanionToolsFinished")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should handle tools finished without tool finished", function()
      tracker.handle_event("CodeCompanionToolStarted")
      tracker.handle_event("CodeCompanionToolsFinished")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Diff State Transitions", function()
    it("should transition to DIFF_AWAITING on diff attached", function()
      tracker.handle_event({match = "CodeCompanionDiffAttached"})
      assert.equals(tracker.State.DIFF_AWAITING, tracker.get_current_state())
    end)

    it("should return to IDLE on diff accepted", function()
      tracker.handle_event({match = "CodeCompanionDiffAttached"})
      tracker.handle_event({match = "CodeCompanionDiffAccepted"})
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should return to IDLE on diff rejected", function()
      tracker.handle_event({match = "CodeCompanionDiffAttached"})
      tracker.handle_event({match = "CodeCompanionDiffRejected"})
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Chat State Handling", function()
    it("should not change state on chat opened", function()
      local initial_state = tracker.get_current_state()
      tracker.handle_event("CodeCompanionChatOpened")
      assert.equals(initial_state, tracker.get_current_state())
    end)

    it("should not change state on chat closed", function()
      tracker.handle_event("CodeCompanionChatOpened")
      tracker.handle_event("CodeCompanionChatClosed")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should handle chat cleared", function()
      tracker.handle_event("CodeCompanionChatCleared")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Complex State Flows", function()
    it("should handle request during tool execution", function()
      -- Start tool
      tracker.handle_event({match = "CodeCompanionToolStarted"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())

      -- Start request (should not interrupt tool flow)
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())

      -- Finish request
      tracker.handle_event({match = "CodeCompanionRequestFinished"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())
    end)

    it("should handle multiple overlapping events", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      tracker.handle_event({match = "CodeCompanionToolStarted"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())

      tracker.handle_event({match = "CodeCompanionToolFinished"})
      tracker.handle_event({match = "CodeCompanionToolsFinished"})
      assert.equals(tracker.State.THINKING, tracker.get_current_state())
    end)
  end)

  describe("State Constants", function()
    it("should have unique state values", function()
      local states = {
        tracker.State.IDLE,
        tracker.State.THINKING,
        tracker.State.RECEIVING,
        tracker.State.TOOLS_RUNNING,
        tracker.State.TOOLS_PROCESSING,
        tracker.State.DIFF_AWAITING
      }

      -- Check all states are unique
      for i = 1, #states do
        for j = i + 1, #states do
          assert.not_equals(states[i], states[j])
        end
      end
    end)

    it("should have reasonable state values", function()
      assert.is_true(tracker.State.IDLE >= 0)
      assert.is_true(tracker.State.THINKING > tracker.State.IDLE)
      assert.is_true(tracker.State.RECEIVING > tracker.State.THINKING)
    end)
  end)

  describe("Event Handling", function()
    it("should handle unknown events gracefully", function()
      local initial_state = tracker.get_current_state()
      tracker.handle_event("UnknownEvent")
      assert.equals(initial_state, tracker.get_current_state())
    end)

    it("should handle empty event", function()
      local initial_state = tracker.get_current_state()
      tracker.handle_event("")
      assert.equals(initial_state, tracker.get_current_state())
    end)

    it("should handle nil event", function()
      local initial_state = tracker.get_current_state()
      tracker.handle_event(nil)
      assert.equals(initial_state, tracker.get_current_state())
    end)
  end)

  describe("State Persistence", function()
    it("should maintain state across multiple calls", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      assert.equals(tracker.State.THINKING, tracker.get_current_state())

      -- Call get_current_state multiple times
      assert.equals(tracker.State.THINKING, tracker.get_current_state())
      assert.equals(tracker.State.THINKING, tracker.get_current_state())
    end)
  end)

  describe("reset()", function()
    it("should reset to IDLE state", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      assert.equals(tracker.State.THINKING, tracker.get_current_state())

      tracker.reset()
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should reset after complex state flow", function()
      tracker.handle_event({match = "CodeCompanionRequestStarted"})
      tracker.handle_event({match = "CodeCompanionRequestStreaming"})
      tracker.handle_event({match = "CodeCompanionToolStarted"})
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())

      tracker.reset()
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)
end)