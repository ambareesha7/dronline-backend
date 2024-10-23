defmodule PatientProfile.ReviewOfSystemTest do
  use Postgres.DataCase, async: true

  alias PatientProfile.ReviewOfSystem

  describe "register_change/2" do
    test "creates new RoS when there's none" do
      form = PatientProfile.Factory.valid_review_of_system_form()

      assert {:ok, %ReviewOfSystem{}} = ReviewOfSystem.register_change(1, form)
    end

    test "returns old RoS if there are no changes" do
      form = PatientProfile.Factory.valid_review_of_system_form()

      {:ok, ros1} = ReviewOfSystem.register_change(1, form)
      {:ok, ros2} = ReviewOfSystem.register_change(1, form)

      assert ros1.id == ros2.id
    end

    test "create new RoS if any field have been changed" do
      form1 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros1} = ReviewOfSystem.register_change(1, form1)

      form2 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros2} = ReviewOfSystem.register_change(1, form2)

      assert ros1.id != ros2.id
      assert ros1.form != ros2.form
    end

    test "doesn't allow empty template" do
      assert_raise(RuntimeError, "invalid form template", fn ->
        form = Proto.Forms.Form.new()
        ReviewOfSystem.register_change(1, form)
      end)
    end

    test "doesn't store information about which specialist provided RoS" do
      form = PatientProfile.Factory.valid_review_of_system_form()

      {:ok, ros} = ReviewOfSystem.register_change(1, form)

      assert is_nil(ros.provided_by_specialist_id)
    end
  end

  describe "register_change/3" do
    test "allows to store information about which specialist provided RoS" do
      form = PatientProfile.Factory.valid_review_of_system_form()

      {:ok, ros} = ReviewOfSystem.register_change(1, form, 2)

      assert ros.provided_by_specialist_id == 2
    end

    test "doesn't override provided_by_specialist_id if form was not changed" do
      form = PatientProfile.Factory.valid_review_of_system_form()

      {:ok, ros1} = ReviewOfSystem.register_change(1, form, 2)
      {:ok, ros2} = ReviewOfSystem.register_change(1, form, 3)

      assert ros1.provided_by_specialist_id == 2
      assert ros2.provided_by_specialist_id == 2

      assert ros1.id == ros2.id
    end

    test "overrides provided_by_specialist_id if form was changed" do
      form = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros1} = ReviewOfSystem.register_change(1, form, 2)

      form = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros2} = ReviewOfSystem.register_change(1, form, 3)

      assert ros1.provided_by_specialist_id == 2
      assert ros2.provided_by_specialist_id == 3

      assert ros1.id != ros2.id
    end
  end

  describe "get_latest/1" do
    test "returns template if patient don't have RoS yet" do
      returned_ros = ReviewOfSystem.get_latest(1)

      assert returned_ros.form.completed == false
    end

    test "returns latest RoS if patient provided it previously" do
      form1 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros1} = ReviewOfSystem.register_change(1, form1)

      form2 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros2} = ReviewOfSystem.register_change(1, form2)

      returned_ros = ReviewOfSystem.get_latest(1)

      assert returned_ros.id == ros2.id
      assert returned_ros.id != ros1.id
      assert returned_ros.form.completed
    end
  end

  describe "fetch_paginated/2" do
    test "returns correct entries when next token is missing" do
      form1 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros1} = ReviewOfSystem.register_change(1, form1)

      form2 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros2} = ReviewOfSystem.register_change(1, form2)

      params = %{"limit" => "1"}

      {:ok, [returned_ros], next_token} = ReviewOfSystem.fetch_paginated(1, params)

      assert returned_ros.id == ros2.id
      assert next_token == NaiveDateTime.to_iso8601(ros1.inserted_at)
    end

    test "returns correct entries when next token is present" do
      form1 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, ros1} = ReviewOfSystem.register_change(1, form1)

      form2 = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, _ros2} = ReviewOfSystem.register_change(1, form2)

      params = %{"limit" => "1", "next_token" => NaiveDateTime.to_iso8601(ros1.inserted_at)}

      {:ok, [returned_ros], next_token} = ReviewOfSystem.fetch_paginated(1, params)

      assert returned_ros.id == ros1.id
      assert next_token == ""
    end
  end
end
