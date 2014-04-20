# Emails related to Sweeps.
class SweepMailer < ActionMailer::Base
  default from: 'Diffux <no-reply@diffux>'

  def ready_for_review(sweep)
    @sweep = sweep
    mail(to: sweep.email, subject: "Re: #{sweep.title}")
  end
end
