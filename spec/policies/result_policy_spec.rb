require 'spec_helper'

require_relative 'owner_policy'

describe ResultPolicy do
  it_behaves_like :owner_policy do
    let(:model) { :result }
  end
end
