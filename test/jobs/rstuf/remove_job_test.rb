require "test_helper"

class Rstuf::RemoveJobTest < ActiveJob::TestCase
  setup do
    setup_rstuf

    @version = create(:version)
    @task_id = "67890"

    stub_request(:post, "#{Rstuf.base_url}/api/v1/artifacts/delete")
      .to_return(
        status: 200,
        body: { data: { task_id: @task_id } }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  test "perform_later enqueues CheckJob with task_id" do
    assert_enqueued_with(at: Time.zone.now + Rstuf.wait_for, job: Rstuf::CheckJob, args: [@task_id]) do
      Rstuf::RemoveJob.perform_now(version: @version)
    end
  end

  teardown do
    teardown_rstuf
  end
end
