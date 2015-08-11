require_relative './omniauth_html_base.rb'

module GrapeTokenAuth
  class OmniAuthSuccessHTML < OmniAuthHTMLBase
    extend Forwardable

    SUCCESS_MESSAGE = 'deliverCredentials'

    def_delegators :oauth_resource, :resource, :persist_oauth_attributes!

    def initialize(oauth_resource, auth_hash, omniauth_params)
      @oauth_resource  = oauth_resource
      @auth_hash       = auth_hash
      @omniauth_params = omniauth_params
    end

    def self.build(resource_class, auth_hash, omniauth_params)
      oauth_resource = OmniAuthResource.fetch_or_create(resource_class,
                                                        auth_hash,
                                                        omniauth_params)
      new(oauth_resource, auth_hash, omniauth_params)
    end

    def auth_origin_url
      auth_url = omniauth_params['auth_origin_url']

      # ensure that hash-bang is present BEFORE querystring for angularjs
      auth_url += '#' unless auth_url.match(/#/)

      "#{auth_url}?#{auth_origin_query_params.to_query}"
    end

    def json_post_data
      success_attributes = { 'message' => SUCCESS_MESSAGE,
                             'config' => omniauth_params['config'] }
      oauth_resource.attributes.merge(success_attributes).to_json
    end

    private

    attr_reader :oauth_resource, :omniauth_params

    def config
      omniauth_params['config_name']
    end

    def auth_origin_query_params
      {
        token:     oauth_resource.token,
        client_id: oauth_resource.client_id,
        uid:       oauth_resource.uid,
        expiry:    oauth_resource.expiry,
        config:    config
      }
    end
  end
end
