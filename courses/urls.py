from django.urls import path, re_path,include
from . import views
from rest_framework.routers import DefaultRouter

app_name = 'courses'
route = DefaultRouter()
route.register('courses', views.CourseViewSet)

# /courses/ - GET
# /courses/ - POST
# /courses/{course_id} - GET
# /courses/{course_id} - PUT
# /courses/{course_id} - DELETE
urlpatterns = [
    path('',include(route.urls)),
]


#urlpatterns = [
#    path('', views.index, name='index'),
#    path('welcome/<int:year>/', views.welcome, name='welcome'),
#    re_path(r'welcome2/(?P<year>[0-9]{4})/$', views.welcome2, name='welcome2'),
#    path('test/', views.TestView.as_view()),
#]

# serializer : chuyen du lieu phuc tap thanh du lieu ra ben ngoai, binh thuong la json
# deserializer nguoc lai : chuyen du lieu don gian thanh du lieu phuc tap cua minh
