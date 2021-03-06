# encoding: utf-8
# Code generated by Microsoft (R) AutoRest Code Generator 0.11.0.0
# Changes may cause incorrect behavior and will be lost if the code is
# regenerated.

module Azure::ARM::Compute
  #
  # VirtualMachineExtensions
  #
  class VirtualMachineExtensions
    include Azure::ARM::Compute::Models
    include MsRestAzure

    #
    # Creates and initializes a new instance of the VirtualMachineExtensions class.
    # @param client service class for accessing basic functionality.
    #
    def initialize(client)
      @client = client
    end

    # @return reference to the ComputeManagementClient
    attr_reader :client

    #
    # The operation to create or update the extension.
    # @param resource_group_name [String] The name of the resource group.
    # @param vm_name [String] The name of the virtual machine where the extension
    # should be create or updated.
    # @param vm_extension_name [String] The name of the virtual machine extension.
    # @param extension_parameters [VirtualMachineExtension] Parameters supplied to
    # the Create Virtual Machine Extension operation.
    # @param @client.api_version [String] Client Api Version.
    # @param @client.subscription_id [String] Gets subscription credentials which
    # uniquely identify Microsoft Azure subscription. The subscription ID forms
    # part of the URI for every service call.
    # @param @client.accept_language [String] Gets or sets the preferred language
    # for the response.
    #
    # @return [Concurrent::Promise] promise which provides async access to http
    # response.
    #
    def create_or_update(resource_group_name, vm_name, vm_extension_name, extension_parameters, custom_headers = nil)
      # Send request
      promise = begin_create_or_update(resource_group_name, vm_name, vm_extension_name, extension_parameters, custom_headers)

      promise = promise.then do |response|
        # Defining deserialization method.
        deserialize_method = lambda do |parsed_response|
          unless parsed_response.nil?
            parsed_response = VirtualMachineExtension.deserialize_object(parsed_response)
          end
        end

        # Waiting for response.
        @client.get_put_operation_result(response, custom_headers, deserialize_method)
      end

      promise
    end

    #
    # The operation to create or update the extension.
    # @param resource_group_name [String] The name of the resource group.
    # @param vm_name [String] The name of the virtual machine where the extension
    # should be create or updated.
    # @param vm_extension_name [String] The name of the virtual machine extension.
    # @param extension_parameters [VirtualMachineExtension] Parameters supplied to
    # the Create Virtual Machine Extension operation.
    # @param [Hash{String => String}] The hash of custom headers need to be
    # applied to HTTP request.
    #
    # @return [Concurrent::Promise] Promise object which allows to get HTTP
    # response.
    #
    def begin_create_or_update(resource_group_name, vm_name, vm_extension_name, extension_parameters, custom_headers = nil)
      fail ArgumentError, 'resource_group_name is nil' if resource_group_name.nil?
      fail ArgumentError, 'vm_name is nil' if vm_name.nil?
      fail ArgumentError, 'vm_extension_name is nil' if vm_extension_name.nil?
      fail ArgumentError, 'extension_parameters is nil' if extension_parameters.nil?
      extension_parameters.validate unless extension_parameters.nil?
      fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
      fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?
      # Construct URL
      path = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{vmName}/extensions/{vmExtensionName}"
      path['{resourceGroupName}'] = ERB::Util.url_encode(resource_group_name) if path.include?('{resourceGroupName}')
      path['{vmName}'] = ERB::Util.url_encode(vm_name) if path.include?('{vmName}')
      path['{vmExtensionName}'] = ERB::Util.url_encode(vm_extension_name) if path.include?('{vmExtensionName}')
      path['{subscriptionId}'] = ERB::Util.url_encode(@client.subscription_id) if path.include?('{subscriptionId}')
      url = URI.join(@client.base_url, path)
      properties = {}
      properties['api-version'] = ERB::Util.url_encode(@client.api_version.to_s) unless @client.api_version.nil?
      unless url.query.nil?
        url.query.split('&').each do |url_item|
          url_items_parts = url_item.split('=')
          properties[url_items_parts[0]] = url_items_parts[1]
        end
      end
      properties.reject!{ |key, value| value.nil? }
      url.query = properties.map{ |key, value| "#{key}=#{value}" }.compact.join('&')
      fail URI::Error unless url.to_s =~ /\A#{URI::regexp}\z/
      corrected_url = url.to_s.gsub(/([^:])\/\//, '\1/')
      url = URI.parse(corrected_url)

      connection = Faraday.new(:url => url) do |faraday|
        faraday.use MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02
        faraday.use :cookie_jar
        faraday.adapter Faraday.default_adapter
      end
      request_headers = Hash.new

      # Set Headers
      request_headers['x-ms-client-request-id'] = SecureRandom.uuid
      request_headers["accept-language"] = @client.accept_language unless @client.accept_language.nil?

      unless custom_headers.nil?
        custom_headers.each do |key, value|
          request_headers[key] = value
        end
      end

      # Serialize Request
      request_headers['Content-Type'] = 'application/json'
      unless extension_parameters.nil?
        extension_parameters = VirtualMachineExtension.serialize_object(extension_parameters)
      end
      request_content = JSON.generate(extension_parameters, quirks_mode: true)

      # Send Request
      promise = Concurrent::Promise.new do
        connection.put do |request|
          request.headers = request_headers
          request.body = request_content
          @client.credentials.sign_request(request) unless @client.credentials.nil?
        end
      end

      promise = promise.then do |http_response|
        status_code = http_response.status
        response_content = http_response.body
        unless (status_code == 201 || status_code == 200)
          error_model = JSON.load(response_content)
          fail MsRestAzure::AzureOperationError.new(connection, http_response, error_model)
        end

        # Create Result
        result = MsRestAzure::AzureOperationResponse.new(connection, http_response)
        result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?
        # Deserialize Response
        if status_code == 201
          begin
            parsed_response = JSON.load(response_content) unless response_content.to_s.empty?
            unless parsed_response.nil?
              parsed_response = VirtualMachineExtension.deserialize_object(parsed_response)
            end
            result.body = parsed_response
          rescue Exception => e
            fail MsRest::DeserializationError.new("Error occured in deserializing the response", e.message, e.backtrace, response_content)
          end
        end
        # Deserialize Response
        if status_code == 200
          begin
            parsed_response = JSON.load(response_content) unless response_content.to_s.empty?
            unless parsed_response.nil?
              parsed_response = VirtualMachineExtension.deserialize_object(parsed_response)
            end
            result.body = parsed_response
          rescue Exception => e
            fail MsRest::DeserializationError.new("Error occured in deserializing the response", e.message, e.backtrace, response_content)
          end
        end

        result
      end

      promise.execute
    end

    #
    # The operation to delete the extension.
    # @param resource_group_name [String] The name of the resource group.
    # @param vm_name [String] The name of the virtual machine where the extension
    # should be deleted.
    # @param vm_extension_name [String] The name of the virtual machine extension.
    # @return [Concurrent::Promise] promise which provides async access to http
    # response.
    #
    def delete(resource_group_name, vm_name, vm_extension_name, custom_headers = nil)
      # Send request
      promise = begin_delete(resource_group_name, vm_name, vm_extension_name, custom_headers)

      promise = promise.then do |response|
        # Defining deserialization method.
        deserialize_method = lambda do |parsed_response|
        end

       # Waiting for response.
       @client.get_post_or_delete_operation_result(response, nil, deserialize_method)
      end

      promise
    end

    #
    # The operation to delete the extension.
    # @param resource_group_name [String] The name of the resource group.
    # @param vm_name [String] The name of the virtual machine where the extension
    # should be deleted.
    # @param vm_extension_name [String] The name of the virtual machine extension.
    # @param [Hash{String => String}] The hash of custom headers need to be
    # applied to HTTP request.
    #
    # @return [Concurrent::Promise] Promise object which allows to get HTTP
    # response.
    #
    def begin_delete(resource_group_name, vm_name, vm_extension_name, custom_headers = nil)
      fail ArgumentError, 'resource_group_name is nil' if resource_group_name.nil?
      fail ArgumentError, 'vm_name is nil' if vm_name.nil?
      fail ArgumentError, 'vm_extension_name is nil' if vm_extension_name.nil?
      fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
      fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?
      # Construct URL
      path = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{vmName}/extensions/{vmExtensionName}"
      path['{resourceGroupName}'] = ERB::Util.url_encode(resource_group_name) if path.include?('{resourceGroupName}')
      path['{vmName}'] = ERB::Util.url_encode(vm_name) if path.include?('{vmName}')
      path['{vmExtensionName}'] = ERB::Util.url_encode(vm_extension_name) if path.include?('{vmExtensionName}')
      path['{subscriptionId}'] = ERB::Util.url_encode(@client.subscription_id) if path.include?('{subscriptionId}')
      url = URI.join(@client.base_url, path)
      properties = {}
      properties['api-version'] = ERB::Util.url_encode(@client.api_version.to_s) unless @client.api_version.nil?
      unless url.query.nil?
        url.query.split('&').each do |url_item|
          url_items_parts = url_item.split('=')
          properties[url_items_parts[0]] = url_items_parts[1]
        end
      end
      properties.reject!{ |key, value| value.nil? }
      url.query = properties.map{ |key, value| "#{key}=#{value}" }.compact.join('&')
      fail URI::Error unless url.to_s =~ /\A#{URI::regexp}\z/
      corrected_url = url.to_s.gsub(/([^:])\/\//, '\1/')
      url = URI.parse(corrected_url)

      connection = Faraday.new(:url => url) do |faraday|
        faraday.use MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02
        faraday.use :cookie_jar
        faraday.adapter Faraday.default_adapter
      end
      request_headers = Hash.new

      # Set Headers
      request_headers['x-ms-client-request-id'] = SecureRandom.uuid
      request_headers["accept-language"] = @client.accept_language unless @client.accept_language.nil?

      unless custom_headers.nil?
        custom_headers.each do |key, value|
          request_headers[key] = value
        end
      end

      # Send Request
      promise = Concurrent::Promise.new do
        connection.delete do |request|
          request.headers = request_headers
          @client.credentials.sign_request(request) unless @client.credentials.nil?
        end
      end

      promise = promise.then do |http_response|
        status_code = http_response.status
        response_content = http_response.body
        unless (status_code == 200 || status_code == 204 || status_code == 202)
          fail MsRestAzure::AzureOperationError.new(connection, http_response)
        end

        # Create Result
        result = MsRestAzure::AzureOperationResponse.new(connection, http_response)
        result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?

        result
      end

      promise.execute
    end

    #
    # The operation to get the extension.
    # @param resource_group_name [String] The name of the resource group.
    # @param vm_name [String] The name of the virtual machine containing the
    # extension.
    # @param vm_extension_name [String] The name of the virtual machine extension.
    # @param expand [String] Name of the property to expand. Allowed value is null
    # or 'instanceView'.
    # @param [Hash{String => String}] The hash of custom headers need to be
    # applied to HTTP request.
    #
    # @return [Concurrent::Promise] Promise object which allows to get HTTP
    # response.
    #
    def get(resource_group_name, vm_name, vm_extension_name, expand = nil, custom_headers = nil)
      fail ArgumentError, 'resource_group_name is nil' if resource_group_name.nil?
      fail ArgumentError, 'vm_name is nil' if vm_name.nil?
      fail ArgumentError, 'vm_extension_name is nil' if vm_extension_name.nil?
      fail ArgumentError, '@client.api_version is nil' if @client.api_version.nil?
      fail ArgumentError, '@client.subscription_id is nil' if @client.subscription_id.nil?
      # Construct URL
      path = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{vmName}/extensions/{vmExtensionName}"
      path['{resourceGroupName}'] = ERB::Util.url_encode(resource_group_name) if path.include?('{resourceGroupName}')
      path['{vmName}'] = ERB::Util.url_encode(vm_name) if path.include?('{vmName}')
      path['{vmExtensionName}'] = ERB::Util.url_encode(vm_extension_name) if path.include?('{vmExtensionName}')
      path['{subscriptionId}'] = ERB::Util.url_encode(@client.subscription_id) if path.include?('{subscriptionId}')
      url = URI.join(@client.base_url, path)
      properties = {}
      properties['$expand'] = ERB::Util.url_encode(expand.to_s) unless expand.nil?
      properties['api-version'] = ERB::Util.url_encode(@client.api_version.to_s) unless @client.api_version.nil?
      unless url.query.nil?
        url.query.split('&').each do |url_item|
          url_items_parts = url_item.split('=')
          properties[url_items_parts[0]] = url_items_parts[1]
        end
      end
      properties.reject!{ |key, value| value.nil? }
      url.query = properties.map{ |key, value| "#{key}=#{value}" }.compact.join('&')
      fail URI::Error unless url.to_s =~ /\A#{URI::regexp}\z/
      corrected_url = url.to_s.gsub(/([^:])\/\//, '\1/')
      url = URI.parse(corrected_url)

      connection = Faraday.new(:url => url) do |faraday|
        faraday.use MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02
        faraday.use :cookie_jar
        faraday.adapter Faraday.default_adapter
      end
      request_headers = Hash.new

      # Set Headers
      request_headers['x-ms-client-request-id'] = SecureRandom.uuid
      request_headers["accept-language"] = @client.accept_language unless @client.accept_language.nil?

      unless custom_headers.nil?
        custom_headers.each do |key, value|
          request_headers[key] = value
        end
      end

      # Send Request
      promise = Concurrent::Promise.new do
        connection.get do |request|
          request.headers = request_headers
          @client.credentials.sign_request(request) unless @client.credentials.nil?
        end
      end

      promise = promise.then do |http_response|
        status_code = http_response.status
        response_content = http_response.body
        unless (status_code == 200)
          error_model = JSON.load(response_content)
          fail MsRestAzure::AzureOperationError.new(connection, http_response, error_model)
        end

        # Create Result
        result = MsRestAzure::AzureOperationResponse.new(connection, http_response)
        result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?
        # Deserialize Response
        if status_code == 200
          begin
            parsed_response = JSON.load(response_content) unless response_content.to_s.empty?
            unless parsed_response.nil?
              parsed_response = VirtualMachineExtension.deserialize_object(parsed_response)
            end
            result.body = parsed_response
          rescue Exception => e
            fail MsRest::DeserializationError.new("Error occured in deserializing the response", e.message, e.backtrace, response_content)
          end
        end

        result
      end

      promise.execute
    end

  end
end
