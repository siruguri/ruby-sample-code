keys = [
  ::ClientCustomization::CustomizationName::NET_OPERATING_INCOME_LEDGER_ID,
  ::ClientCustomization::CustomizationName::NON_OPERATING_EXPENSES_LEDGER_ID,
  ::ClientCustomization::CustomizationName::OPERATING_EXPENSES_LEDGER_ID,
  ::ClientCustomization::CustomizationName::OPERATING_INCOME_LEDGER_ID,
  ::ClientCustomization::CustomizationName::LOCKED_FOR_ONSITE_LEDGER_ID,
]

def display(key)
  key.gsub(/::ClientCustomization::CustomizationName/, '').downcase.gsub(/_/, ' ')
end

Organization.yardi.active.order(:subdomain).each do |org|
  custom = org.unsafe_client_customization

  keys.each do |key|
    if custom.customizations[key]
      title = custom.customizations[key]['title']
      codename = custom.customizations[key]['codename']
    end
    puts "#{org.subdomain},#{display(key)},\"#{title}\",\"#{codename}\"" #if !custom.customizations[key].blank?
  end
end

  
