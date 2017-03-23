<?php

namespace Intracto\SecretSantaBundle\Command;

use Symfony\Bundle\FrameworkBundle\Command\ContainerAwareCommand;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Doctrine\ORM\EntityManager;

class SendPoolStatusCommand extends ContainerAwareCommand
{
    /**
     * Configure the command options.
     */
    protected function configure()
    {
        $this
            ->setName('intracto:sendPoolStatusMails')
            ->setDescription('Send pool status mail to admins');
    }

    /**
     * Execute the command.
     *
     * @param InputInterface  $input
     * @param OutputInterface $output
     *
     * @return int|null
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $container = $this->getContainer();
        /** @var EntityManager $em */
        $em = $container->get('doctrine')->getManager();
        /** @var \Intracto\SecretSantaBundle\Query\ParticipantMailQuery $entryMailQuery */
        $entryMailQuery = $container->get('intracto_secret_santa.participant_mail');
        $mailerService = $container->get('intracto_secret_santa.mail');
        $partyAdmins = $entryMailQuery->findAllAdminsForPoolStatusMail();
        $timeNow = new \DateTime();

        try {
            foreach ($partyAdmins as $poolAdmin) {
                $mailerService->sendPoolStatusMail($poolAdmin);

                $poolAdmin->setPoolStatusSentTime($timeNow);
                $em->persist($poolAdmin);
            }

            $em->flush();
        } catch (\Exception $e) {
            throw $e;
        } finally {
            $em->flush();
        }
    }
}
