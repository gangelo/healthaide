import SearchFormController from "controllers/search_form_controller";

/**
 * HealthGoalSearchFormController specializes the SearchFormController for health goal searches
 */
export default class HealthGoalSearchFormController extends SearchFormController {
  static targets = [...SearchFormController.targets, "container"]
  
  static values = {
    ...SearchFormController.values,
    listFrameId: { type: String, default: "health_goals_list" },
    resourceType: { type: String, default: "health_goal" },
    searchPath: { type: String, default: "/user_health_goals/select_multiple" }
  }
  
  connect() {
    super.connect();
    this.searchTimeout = null;
  }
}