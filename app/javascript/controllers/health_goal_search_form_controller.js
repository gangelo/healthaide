import SearchFormController from "controllers/search_form_controller";

/**
 * HealthGoalSearchFormController specializes the SearchFormController for health goal searches
 */
export default class HealthGoalSearchFormController extends SearchFormController {
  static values = {
    ...SearchFormController.values,
    frame: { type: String, default: "goals_list" },
    url: { type: String, default: "/user_health_goals/select_multiple?frame_id=goals_list" }
  }
  
  getDefaultFrameId() {
    return "goals_list";
  }
}