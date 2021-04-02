require 'spec_helper'


RSpec.describe Pork::Formatter do
  it "to_h" do
    arr_of_arr = [
      %w(123 12345 1234),
      %w(1234 123 1234),
    ]
    formatter = Pork::Formatter.new()
    actual = formatter.format(arr_of_arr)
    expect(actual).to eq([
      ['123 ', '12345', '1234'],
      ['1234', '123  ', '1234'],
    ])
  end
end
