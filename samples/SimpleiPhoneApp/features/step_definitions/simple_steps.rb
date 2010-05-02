Given /^a new run$/ do
#  app.restart
end

Then /^I should see a button labelled "(A Button)"$/ do |button_label|
#  puts app.instance_variable_get( '@gui' ).dump
#  puts "//UIButton/**/text/text()='#{button_label}'"
  element = app.button_with_label( button_label )
  element.should_not be_nil
  element.size.should == 1
end
