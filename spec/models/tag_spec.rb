# == Schema Information
#
# Table name: tags
#
#  id           :bigint           not null, primary key
#  name(名前)   :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "rails_helper"

RSpec.describe Tag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
