class TestAvailabilitiesController < ApplicationController
  def index
    authorize!
    @tests = wrap_language(Test.all.select(:name, :id))
    @query = User
      .all_local_admins
      .joins(:employee)
      .select('users.*, employees.organisation')
      .includes(:test_availabilities)
      .ransack(params[:q])
    @users = @query.result

  end

  def batch_update
    authorize!

    params.require(:payload).each do |index, param|
      begin
        payload = role_params(param)
        test_availability = TestAvailability.find(payload[:id])
        test_availability.update!(payload)
      rescue ActiveRecord::RecordInvalid
        render json: { },
               status: :bad_request
      end
    end

    render json: {
        msg: tf('common.flash.role_updated')
    }, status: :created
  end

  private

    def role_params(param)
      param
        .require(:test_availabilities)
        .permit(:id, :available)
    end
end
