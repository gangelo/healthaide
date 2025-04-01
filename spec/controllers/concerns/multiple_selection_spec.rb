# frozen_string_literal: true

require "rails_helper"

# Create a test controller to test the MultipleSelection concern
class TestController < ApplicationController
  include MultipleSelection

  def resource_type
    :food
  end

  def resource_path
    "user_foods"
  end

  def search_items_for_user(query)
    Food.all
  end

  def add_items_to_user(item_ids)
    item_ids.size
  end
end

RSpec.describe MultipleSelection, type: :concern do
  let(:controller) { TestController.new }

  before do
    # Setup controller request and response objects
    allow(controller).to receive(:params).and_return(ActionController::Parameters.new)
    allow(controller).to receive(:current_user).and_return(create(:user))
    allow(controller).to receive(:flash).and_return({})
    allow(controller).to receive(:turbo_frame_request?).and_return(false)
    allow(controller).to receive(:render)
    allow(controller).to receive(:redirect_to)
    allow(controller).to receive(:respond_to).and_yield(double(turbo_stream: true, html: true))
  end

  describe "#item_id_param_name" do
    it "returns the correct parameter name based on resource_type" do
      expect(controller.send(:item_id_param_name)).to eq("food_ids")
    end
  end

  describe "#items_local_name" do
    it "returns the pluralized resource type as a string" do
      expect(controller.send(:items_local_name)).to eq("foods")
    end
  end

  describe "#list_frame_id" do
    it "returns the correct frame ID based on resource_type" do
      expect(controller.send(:list_frame_id)).to eq("foods_list")
    end
  end

  describe "#handle_empty_selection" do
    it "sets a flash alert message" do
      expect(controller).to receive(:respond_to).and_yield(double(turbo_stream: true, html: true))
      expect(controller.flash).to receive(:[]=).with(:alert, "Please select at least one food.")
      controller.send(:handle_empty_selection)
    end
  end

  describe "#handle_successful_addition" do
    it "sets a flash notice message" do
      message = "2 foods successfully added."
      expect(controller).to receive(:respond_to).and_yield(double(turbo_stream: true, html: true))
      expect(controller.flash).to receive(:[]=).with(:notice, message)
      controller.send(:handle_successful_addition, message)
    end
  end

  describe "#handle_error" do
    it "sets a flash alert message with the exception message" do
      exception = StandardError.new("Test error")
      expect(controller).to receive(:respond_to).and_yield(double(turbo_stream: true, html: true))
      expect(controller.flash).to receive(:[]=).with(:alert, "Error adding foods: Test error")
      controller.send(:handle_error, exception)
    end
  end

  describe "#add_multiple" do
    context "when item_ids are blank" do
      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(food_ids: [""]))
      end

      it "calls handle_empty_selection" do
        expect(controller).to receive(:handle_empty_selection)
        controller.add_multiple
      end
    end

    context "when item_ids are present" do
      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(food_ids: ["1", "2"]))
      end

      it "calls add_items_to_user and handle_successful_addition" do
        expect(controller).to receive(:add_items_to_user).with(["1", "2"]).and_return(2)
        expect(controller).to receive(:handle_successful_addition).with("2 foods successfully added.")
        controller.add_multiple
      end
    end

    context "when an error occurs" do
      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(food_ids: ["1", "2"]))
        allow(controller).to receive(:add_items_to_user).and_raise(StandardError.new("Test error"))
      end

      it "calls handle_error with the exception" do
        expect(controller).to receive(:handle_error).with(an_instance_of(StandardError))
        controller.add_multiple
      end
    end
  end

  describe "#select_multiple" do
    context "when search param is present" do
      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(search: "test"))
      end

      it "calls search_items_for_user with the search parameter" do
        expect(controller).to receive(:search_items_for_user).with("test")
        controller.select_multiple
      end
    end

    context "when receiving a turbo frame request for the list frame" do
      before do
        allow(controller).to receive(:turbo_frame_request?).and_return(true)
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(frame_id: "foods_list")
        )
      end

      it "renders the list_frame template" do
        expect(controller).to receive(:render).with(
          "user_foods/select/list_frame", {:locals => {"foods" => anything}}
        )
        controller.select_multiple
      end
    end

    context "when receiving a turbo frame request for the modal" do
      before do
        allow(controller).to receive(:turbo_frame_request?).and_return(true)
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new)
      end

      it "renders the modal partial" do
        expect(controller).to receive(:render).with(
          :partial => "user_foods/select/modal", :locals => {"foods" => anything}
        )
        controller.select_multiple
      end
    end
  end
end