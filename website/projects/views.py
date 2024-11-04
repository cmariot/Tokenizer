from django.views.generic import TemplateView
from account.models import UserProject


class Home(TemplateView):

    template_name = 'projects/templates/base.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if self.request.user.is_authenticated:
            print("User is authenticated")
            context['projects'] = UserProject.objects.filter(
                user=self.request.user
            )
        else:
            print("User is not authenticated")
        return context