require 'spec_helper'

require_relative 'owner_policy'

describe ArenaPolicy do
  it_behaves_like :owner_policy do
    let(:model) { :arena }
  end
end
