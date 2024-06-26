require 'json'
require 'uri'

module ArchiveAPI

  def get_raw_list_from_api(url, page_index, http)
    request_url = URI("https://web.archive.org/cdx/search/xd")
    params = [["output", "json"], ["url", url]] + parameters_for_api(page_index)
    request_url.query = URI.encode_www_form(params)

    begin
      response = http.get(request_url)
      json = JSON.parse(response.body)

      # Check if the response contains the header ["timestamp", "original"]
      json.shift if json.first == ["timestamp", "original"]
      json
    rescue JSON::ParserError, StandardError => e
      warn "Failed to fetch data from API: #{e.message}"
      []
    end
  end

  def parameters_for_api(page_index)
    parameters = [["fl", "timestamp,original"], ["collapse", "digest"], ["gzip", "false"]]
    parameters.push(["filter", "statuscode:200"]) unless @all
    parameters.push(["from", @from_timestamp.to_s]) if @from_timestamp && @from_timestamp != 0
    parameters.push(["to", @to_timestamp.to_s]) if @to_timestamp && @to_timestamp != 0
    parameters.push(["page", page_index]) if page_index
    parameters
  end

end
