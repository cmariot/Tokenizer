# Generated by Django 5.1.1 on 2024-11-22 14:36

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0011_project_description_alter_project_name'),
    ]

    operations = [
        migrations.AddField(
            model_name='userproject',
            name='ipfs_metadata',
            field=models.TextField(blank=True, null=True),
        ),
    ]