Given(/^this step is passing$/) do
  expect(true).to be true
end

Given(/^this step is pending$/) do
  pending
end

Given(/^this step is failing$/) do
  expect(true).to be false
end
