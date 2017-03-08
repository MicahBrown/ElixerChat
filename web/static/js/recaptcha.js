export function setVerifcationRequirement (recaptcha){
  var req = recaptcha.dataset.required

  if (typeof req == "string")
    req = req == "true"

  return req
};
