# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ExportsController, type: :controller do
        routes { Decidim::Conferences::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:conference) { create :conference, organization: organization }
        let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let!(:component) { create(:component, participatory_space: conference, manifest_name: "dummy") }

        let(:params) do
          {
            id: "dummies",
            component_id: component.id,
            conference_slug: conference.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create" do
          context "when a format is provided" do
            it "enqueues a job with the provided format" do
              params[:format] = "csv"

              expect(ExportJob).to receive(:perform_later)
                .with(user, component, "dummies", "csv")

              post(:create, params: params)
            end
          end

          context "when a format is not provided" do
            it "enqueues a job with the default format" do
              expect(ExportJob).to receive(:perform_later)
                .with(user, component, "dummies", "json")

              post(:create, params: params)
            end
          end
        end
      end
    end
  end
end
