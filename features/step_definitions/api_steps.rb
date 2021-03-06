When %{I request "$path"} do |path|
  wait do
    @response = Pusher.get(path)
  end
end

When %{I request "$path" with the following options:} do |path, table|
  wait do
    begin
      @response = Pusher.get(path, table.hashes.first)
    rescue => error
      @error = error
    end
  end
end

Then %{I should receive the following JSON:} do |string|
  expected = MultiJson.load(string)
  expected = expected.inject({}) do |result, (key, value)|
    result[key.to_sym] = value
    result
  end

  @response.should == expected
end

Then %{I should receive the following error:} do |string|
  @error.message.should include(string.strip)
end

Then /^I should receive JSON for (\d+) users?$/ do |count|
  users = @response[:users]
  users.length.should == count.to_i
  users.each do |user|
    object = ObjectSpace._id2ref(user["id"])
    object.should be_a(PusherFake::Connection)
  end
end
