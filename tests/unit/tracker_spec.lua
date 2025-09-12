local tracker = require("codecompanion._extensions.spinner.tracker")

describe("Tracker Module", function()
  before_each(function()
    -- Reset tracker state before each test
    tracker.reset()
  end)

  describe("State Management", function()
    it("should start in IDLE state", function()
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should transition to THINKING on request started", function()
      tracker.handle_event("CodeCompanionRequestStarted")
      assert.equals(tracker.State.THINKING, tracker.get_current_state())
    end)

    it("should transition to RECEIVING on request streaming", function()
      tracker.handle_event("CodeCompanionRequestStarted")
      tracker.handle_event("CodeCompanionRequestStreaming")
      assert.equals(tracker.State.RECEIVING, tracker.get_current_state())
    end)

    it("should return to IDLE on request finished", function()
      tracker.handle_event("CodeCompanionRequestStarted")
      tracker.handle_event("CodeCompanionRequestFinished")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Tool State Management", function()
    it("should transition to TOOLS_RUNNING on tool started", function()
      tracker.handle_event("CodeCompanionToolStarted")
      assert.equals(tracker.State.TOOLS_RUNNING, tracker.get_current_state())
    end)

    it("should transition to TOOLS_PROCESSING on tool finished", function()
      tracker.handle_event("CodeCompanionToolStarted")
      tracker.handle_event("CodeCompanionToolFinished")
      assert.equals(tracker.State.TOOLS_PROCESSING, tracker.get_current_state())
    end)

    it("should return to IDLE on tools finished", function()
      tracker.handle_event("CodeCompanionToolStarted")
      tracker.handle_event("CodeCompanionToolFinished")
      tracker.handle_event("CodeCompanionToolsFinished")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Diff State Management", function()
    it("should transition to DIFF_AWAITING on diff attached", function()
      tracker.handle_event("CodeCompanionDiffAttached")
      assert.equals(tracker.State.DIFF_AWAITING, tracker.get_current_state())
    end)

    it("should return to IDLE on diff accepted", function()
      tracker.handle_event("CodeCompanionDiffAttached")
      tracker.handle_event("CodeCompanionDiffAccepted")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)

    it("should return to IDLE on diff rejected", function()
      tracker.handle_event("CodeCompanionDiffAttached")
      tracker.handle_event("CodeCompanionDiffRejected")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("Chat State Management", function()
    it("should handle chat events without changing state", function()
      tracker.handle_event("CodeCompanionChatOpened")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())

      tracker.handle_event("CodeCompanionChatClosed")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("State Constants", function()
    it("should have all required state constants", function()
      assert.is_number(tracker.State.IDLE)
      assert.is_number(tracker.State.THINKING)
      assert.is_number(tracker.State.RECEIVING)
      assert.is_number(tracker.State.TOOLS_RUNNING)
      assert.is_number(tracker.State.TOOLS_PROCESSING)
      assert.is_number(tracker.State.DIFF_AWAITING)
    end)

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
  end)

  describe("Event Handling", function()
    it("should handle unknown events gracefully", function()
      local initial_state = tracker.get_current_state()
      tracker.handle_event("UnknownEvent")
      assert.equals(initial_state, tracker.get_current_state())
    end)

    it("should handle multiple events in sequence", function()
      tracker.handle_event("CodeCompanionRequestStarted")
      assert.equals(tracker.State.THINKING, tracker.get_current_state())

      tracker.handle_event("CodeCompanionRequestStreaming")
      assert.equals(tracker.State.RECEIVING, tracker.get_current_state())

      tracker.handle_event("CodeCompanionRequestFinished")
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)

  describe("reset()", function()
    it("should reset to IDLE state", function()
      tracker.handle_event("CodeCompanionRequestStarted")
      assert.equals(tracker.State.THINKING, tracker.get_current_state())

      tracker.reset()
      assert.equals(tracker.State.IDLE, tracker.get_current_state())
    end)
  end)
end)