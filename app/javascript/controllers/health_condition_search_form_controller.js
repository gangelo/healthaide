import SearchFormController from "controllers/search_form_controller";

/**
 * HealthConditionSearchFormController specializes the SearchFormController for health condition searches
 */
export default class HealthConditionSearchFormController extends SearchFormController {
  static values = {
    ...SearchFormController.values,
    frame: { type: String, default: "conditions_list" },
    url: { type: String, default: "/user_health_conditions/select_multiple?frame_id=conditions_list" }
  }
  
  getDefaultFrameId() {
    return "conditions_list";
  }
}
